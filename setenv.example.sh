# Copy to setenv.sh (gitignored) or export before launching Tomcat.
export OPENMES_DB_URL="jdbc:postgresql://localhost:5432/openmes"
export OPENMES_DB_USER="openmes"
export OPENMES_DB_PASSWORD="change-me"
export OPENMES_BASE_URL="https://games.donotpassgo.co.uk/openmes"
export OPENMES_ENVIRONMENT="DEV"
# First boot only: if users table is empty, seeds IT_ADMIN user "admin"
export OPENMES_BOOTSTRAP_PASSWORD="change-me-now"
# Optional:
# export OPENMES_DB_POOL=8
# export OPENMES_TEST_MODE=true
