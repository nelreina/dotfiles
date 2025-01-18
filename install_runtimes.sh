#!/bin/bash

curl -fsSL https://deno.land/install.sh | sh
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash

nvm install node

node -v
deno -v
