#!/usr/bin/env python3

import json
import os
import sys
import base64
import requests
from nacl import encoding, public

# Required environment variables
GITHUB_TOKEN = os.getenv("GITHUB_TOKEN")
GITHUB_REPOSITORY = os.getenv("GITHUB_REPOSITORY")  # owner/repo

if not GITHUB_TOKEN or not GITHUB_REPOSITORY:
    print("Missing GITHUB_TOKEN or GITHUB_REPOSITORY")
    sys.exit(1)

OWNER, REPO = GITHUB_REPOSITORY.split("/")


# Load Terraform outputs
try:
    with open("outputs.json") as f:
        tf_outputs = json.load(f)
except FileNotFoundError:
    print("outputs.json not found. Did you run terraform output -json?")
    sys.exit(1)


# Map Terraform outputs → GitHub Secrets
SECRETS_MAP = {
    "ASG_SERVER_IPS": tf_outputs["asg_instance_public_ips"]["value"],
    "LOAD_BALANCER_DNS_NAME": tf_outputs["load_balancer_dns_name"]["value"],
    "REDIS_ENDPOINT": tf_outputs["redis_primary_endpoint"]["value"],
    "CLOUDFRONT_DISTRIBUTION_ID": tf_outputs["distribution_id"]["value"],
    "CLOUDFRONT_URL": tf_outputs["cloudfront_url"]["value"],
}


# GitHub API helpers
HEADERS = {
    "Authorization": f"Bearer {GITHUB_TOKEN}",
    "Accept": "application/vnd.github+json",
}

def get_repo_public_key():
    url = f"https://api.github.com/repos/{OWNER}/{REPO}/actions/secrets/public-key"
    r = requests.get(url, headers=HEADERS)
    r.raise_for_status()
    return r.json()

def encrypt_secret(public_key: str, value: str) -> str:
    pk = public.PublicKey(public_key.encode("utf-8"), encoding.Base64Encoder())
    sealed_box = public.SealedBox(pk)
    encrypted = sealed_box.encrypt(value.encode("utf-8"))
    return base64.b64encode(encrypted).decode("utf-8")

def update_secret(name: str, value: str, key_id: str, public_key: str):
    encrypted_value = encrypt_secret(public_key, value)
    url = f"https://api.github.com/repos/{OWNER}/{REPO}/actions/secrets/{name}"

    payload = {
        "encrypted_value": encrypted_value,
        "key_id": key_id,
    }

    r = requests.put(url, headers=HEADERS, json=payload)
    r.raise_for_status()


# Main
def main():
    print("Fetching GitHub repository public key...")
    key_data = get_repo_public_key()
    public_key = key_data["key"]
    key_id = key_data["key_id"]

    for secret_name, secret_value in SECRETS_MAP.items():
        if isinstance(secret_value, list):
            secret_value = ",".join(secret_value)

        print(f"Updating secret: {secret_name}")
        update_secret(secret_name, str(secret_value), key_id, public_key)

    print("GitHub secrets updated successfully")

if __name__ == "__main__":
    main()
