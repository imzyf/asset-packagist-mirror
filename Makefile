.PHONY: help sync clean

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
		| awk 'BEGIN{FS=":.*?## "}{printf "  \033[36m%-8s\033[0m %s\n", $$1, $$2}'

sync: ## Sync the mirror from upstream and regenerate packages.json
	@./bin/sync.sh

clean: ## Remove the local download cache
	@rm -rf .cache
	@echo "removed .cache"
