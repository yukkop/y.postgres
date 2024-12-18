CONFIG_FILE=postgresql.conf && \
    extensions="" && \
    [ "$INSTALL_CRON" = "true" ] && extensions="$extensions pg_cron" && \
    [ "$INSTALL_PLRUST" = "true" ] && extensions="$extensions plrust" && \
    extensions=$(echo $extensions | xargs | sed 's/ /,/g') && \
    if grep -q "^[^#]*shared_preload_libraries" "$CONFIG_FILE"; then \
      current=$(grep "^[^#]*shared_preload_libraries" "$CONFIG_FILE" | sed -E "s/shared_preload_libraries\s*=\s*'(.*)'/\1/"); \
      new_libraries="$current"; \
      # Iterate over each extension
      for ext in $(echo "$extensions" | tr ',' ' '); do \
        # Check if ext is already in current
        echo "$current" | grep -wq "$ext" || { \
          if [ -z "$new_libraries" ]; then \
            new_libraries="$ext"; \
          else \
            new_libraries="$new_libraries,$ext"; \
          fi; \
        } \
      done; \
      sed -i "s/^\([^#]*shared_preload_libraries\s*=\s*'\).*'/\1${new_libraries}'/" "$CONFIG_FILE"; \
    else \
      if grep -q "^#.*shared_preload_libraries" "$CONFIG_FILE"; then \
        sed -i "s/^#.*shared_preload_libraries\s*=.*/shared_preload_libraries = '${extensions}'/" "$CONFIG_FILE"; \
      else \
        echo "shared_preload_libraries = '${extensions}'" >> "$CONFIG_FILE"; \
      fi; \
    fi
