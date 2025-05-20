## Docker Image Management Script

This script automates the process of building, tagging, pushing, and pulling Docker images to and from Google Artifact Registry. It is specifically designed for use with Google Cloud Platform (GCP) and requires a service account with the necessary permissions.
Run this within the directory where Dockerfile is located or add path to it.

### Usage

1. Ensure you have a service account key file and set the `GOOGLE_APPLICATION_CREDENTIALS` environment variable to point to it.
2. Run the script to build, tag, push, and pull Docker images.

```bash
./docker-image-management.sh
```

This script is only applicable for GCP and will not work with other cloud providers. 