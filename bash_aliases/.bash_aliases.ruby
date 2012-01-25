alias gem-uninstall-all="gem list | awk '{print \$1}' | xargs gem uninstall -aIx"
