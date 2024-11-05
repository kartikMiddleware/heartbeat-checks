# Makefile for generating PlantUML diagrams and Git operations

# Define the PlantUML command
PLANTUML=plantuml

# Default commit message and directory
DEFAULT_MSG="updated files"
DEFAULT_DIR="."

# Rule to generate SVG from PlantUML and perform Git operations
gen: svg git

# Rule to generate SVG from PlantUML
svg:
	@if [ -z "$(dir)" ]; then \
		echo "Usage: make gen dir=<directory> [msg=<commit message>]"; \
		exit 1; \
	fi
	@command -v $(PLANTUML) >/dev/null 2>&1 || { echo >&2 "$(PLANTUML) is not installed. Aborting."; exit 1; }
	$(PLANTUML) -tsvg $(dir)/sequence-diagrams.md

# Rule to add, commit, and push to GitHub
git:
	@if [ -z "$msg" ]; then \
		commit_msg="$(DEFAULT_MSG)"; \
		echo "No commit message provided. Using default: '$(DEFAULT_MSG)'"; \
	else \
		commit_msg="$(msg)"; \
	fi; \
	echo "what $(commit_msg)"; \

	@if [ -z "$dir" ]; then \
		dir="$DEFAULT_DIR"; \
	fi; \

	git add "$$dir"; \
	
	@if git diff-index --quiet HEAD --; then \
		echo "No changes to commit."; \
	else \
		git commit -m "$$commit_msg"; \
		git push; \
	fi

.PHONY: gen svg git
