.PHONY: build gw-docker-build gw-docker-run gw-docker-push gw-deploy clean generate

PROJECT_ID = labs-169405
IMAGE_NAME = jennah-gateway
IMAGE_TAG = latest
AR_IMAGE = asia-docker.pkg.dev/$(PROJECT_ID)/asia.gcr.io/$(IMAGE_NAME):$(IMAGE_TAG)


# Generate codes from proto changes
generate:
	buf generate --exclude-path vendor/

# Build gateway binary 
gw-build:
	cd cmd/gateway && go build -o ../../bin/gateway main.go

# Build the gateway Docker image
gw-docker-build:
	docker build -f Dockerfile.gateway -t $(IMAGE_NAME):$(IMAGE_TAG) .
	docker tag $(IMAGE_NAME):$(IMAGE_TAG) $(AR_IMAGE)

# Run the gateway Docker container locally
gw-docker-run:
	docker run --rm -p 8080:8080 $(IMAGE_NAME):$(IMAGE_TAG)

# Push the gateway Docker image to Artifact Registry
gw-docker-push:
	gcloud auth configure-docker asia-docker.pkg.dev
	docker push $(AR_IMAGE)

# Deploy the gateway Docker image to Cloud Run
gw-deploy:
	gcloud run deploy $(IMAGE_NAME) \
	  --image $(AR_IMAGE) \
	  --platform managed \
	  --region asia-northeast1 \
	  --port 8080

clean:
	rm -rf bin/
	docker rmi $(IMAGE_NAME):$(IMAGE_TAG) 2>/dev/null || true
	docker rmi $(AR_IMAGE) 2>/dev/null || true