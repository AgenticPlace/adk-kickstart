#!/bin/bash

# This script automates the setup for a basic Google ADK agent project.
# It creates a virtual environment, installs ADK, and generates
# the necessary directory structure and template files.

# Exit immediately if a command exits with a non-zero status.
set -e

# --- Configuration ---
VENV_NAME="augmentic_adk_env" # Renamed for clarity
PARENT_DIR_NAME="adk_agent_project" # Renamed for clarity
AGENT_DIR_NAME="multi_tool_agent"
PROJECT_DIR="${PARENT_DIR_NAME}/${AGENT_DIR_NAME}"
PYTHON_CMD="python3" # Assumes python3 is available

# --- Script Start ---
echo "====================================================="
echo " Starting Google ADK Agent Setup (Weather/Time) "
echo "====================================================="
echo "This script will create:"
echo "  - Python virtual environment: ./${VENV_NAME}"
echo "  - Project structure:        ./${PROJECT_DIR}"
echo "WARNING: Existing files in ./${PROJECT_DIR} may be overwritten."
read -p "Press Enter to continue, or Ctrl+C to cancel..."

echo
echo "--- Phase 1: Setting up Environment & Dependencies ---"

# 1. Create Python Virtual Environment
echo "[1/3] Creating Python virtual environment './${VENV_NAME}'..."
if ! ${PYTHON_CMD} -m venv ${VENV_NAME}; then
    echo "ERROR: Failed to create virtual environment using '${PYTHON_CMD} -m venv'. Ensure Python 3 and the 'venv' module are correctly installed."
    exit 1
fi
echo "      Virtual environment created."

# Activate within the script's subshell for installation
echo "      Activating virtual environment for installation..."
source ${VENV_NAME}/bin/activate

# 2. Install ADK and Dependencies
echo "[2/3] Installing google-adk and tzdata packages..."
if ! pip install --quiet google-adk tzdata; then # Added tzdata, --quiet reduces noise
    echo "ERROR: Failed to install required packages (google-adk, tzdata). Check pip and network connection."
    # Consider cleaning up venv on failure?
    # deactivate
    exit 1
fi
echo "      google-adk and tzdata installed successfully."

# 3. Verify ADK Installation (Optional but Recommended)
echo "[3/3] Verifying google-adk installation..."
pip show google-adk || echo "      Verification command failed, but installation might still be okay."

# Deactivate script's subshell activation
# deactivate

echo "--- Environment Setup Complete ---"
echo

echo "--- Phase 2: Creating Agent Project Files ---"

# 1. Create Project Directory Structure
echo "[1/4] Creating project structure './${PROJECT_DIR}'..."
mkdir -p ${PROJECT_DIR}
echo "      Directory structure created."

# 2. Create __init__.py
echo "[2/4] Creating '${PROJECT_DIR}/__init__.py'..."
echo "from . import agent" > ${PROJECT_DIR}/__init__.py
echo "      __init__.py created."

# 3. Create agent.py
echo "[3/4] Creating '${PROJECT_DIR}/agent.py'..."
# Use cat with heredoc for multi-line content, preventing shell expansion
cat << 'EOF' > ${PROJECT_DIR}/agent.py
import datetime
import logging
from zoneinfo import ZoneInfo
# Use LlmAgent for models like Gemini
from google.adk.agents import LlmAgent
from google.adk.tools import FunctionTool

# Setup basic logging for visibility inside the agent/tools when run via adk web/run
logging.basicConfig(level=logging.INFO, format='%(asctime)s [%(levelname)s] %(name)s: %(message)s')
logger = logging.getLogger(__name__)

# Define tool functions
def get_weather(city: str) -> dict:
    """Retrieves the current weather report for a specified city.

    Args:
        city (str): The name of the city for which to retrieve the weather report.

    Returns:
        dict: status and result or error msg.
    """
    logger.info(f"Tool Function: get_weather called with city='{city}'")
    # Simulate API call - only works for New York in this example
    if city.lower() == "new york":
        return {
            "status": "success",
            "report": (
                "The weather in New York is sunny with a temperature of 25 degrees"
                " Celsius (77 degrees Fahrenheit)." # Corrected Fahrenheit
            ),
        }
    else:
        logger.warning(f"Weather info for '{city}' not available.")
        return {
            "status": "error",
            "error_message": f"Weather information for '{city}' is not available.",
        }


def get_current_time(city: str) -> dict:
    """Returns the current time in a specified city.

    Args:
        city (str): The name of the city for which to retrieve the current time.

    Returns:
        dict: status and result or error msg.
    """
    logger.info(f"Tool Function: get_current_time called with city='{city}'")
    # Simulate timezone lookup - only works for New York
    if city.lower() == "new york":
        tz_identifier = "America/New_York"
    else:
        logger.warning(f"Timezone info for '{city}' not available.")
        return {
            "status": "error",
            "error_message": (
                f"Sorry, I don't have timezone information for {city}."
            ),
        }

    try:
        # ZoneInfo requires the 'tzdata' package on some systems (installed by setup script)
        tz = ZoneInfo(tz_identifier)
        now = datetime.datetime.now(tz)
        report = (
            f'The current time in {city} ({tz_identifier}) is {now.strftime("%Y-%m-%d %H:%M:%S %Z%z")}'
        )
        return {"status": "success", "report": report}
    except Exception as e:
        # Handle potential ZoneInfo errors or other datetime issues
        logger.error(f"Error in get_current_time for {city}: {e}", exc_info=True)
        return {"status": "error", "error_message": f"Error getting time for {city}: {e}"}

# Explicitly wrap functions in FunctionTool (standard ADK practice)
tools_list = [
    FunctionTool(func=get_weather),
    FunctionTool(func=get_current_time)
]

# Define the root agent using LlmAgent
root_agent = LlmAgent(
    name="weather_time_agent",
    # Ensure model name is current and accessible via your configured API key/Vertex setup
    # Check ADK documentation for available models.
    model="gemini-1.5-flash-latest", # Or "gemini-pro" or other compatible model
    description=(
        "An agent that can provide the current time and weather information, currently only for New York City."
    ),
    instruction=(
        "You are a helpful assistant that provides weather and time information. "
        "Currently, you ONLY have information for New York City (NYC). "
        "Use the available tools ('get_weather', 'get_current_time') when asked about time or weather in NYC. "
        "If asked about any other city, politely state that you only have information for New York City and cannot fulfill the request."
    ),
    tools=tools_list,
)

logger.info(f"ADK Agent '{root_agent.name}' defined successfully in agent.py")

EOF
echo "      agent.py created with example agent."

# 4. Create .env file template
echo "[4/4] Creating '.env' file (template)..."
cat << 'EOF' > ${PROJECT_DIR}/.env
# --- .env Configuration ---
# Instructions: Uncomment and fill ONLY ONE section below (either Option 1 OR Option 2).
# Ensure you replace placeholder values with your actual credentials/project info.
# Make sure there are no leading/trailing spaces around the '=' sign or quotes unless intended.

# --- Option 1: Using Gemini via Google AI Studio API Key ---
# 1. Get a key from https://aistudio.google.com/app/apikey
# 2. Uncomment the two lines below.
# 3. Replace PASTE_YOUR_ACTUAL_API_KEY_HERE with your key.
#
# GOOGLE_GENAI_USE_VERTEXAI="False"
# GOOGLE_API_KEY="PASTE_YOUR_ACTUAL_API_KEY_HERE"


# --- Option 2: Using Gemini via Vertex AI on Google Cloud ---
# 1. Ensure you have a GCP Project and enabled the Vertex AI API.
# 2. Authenticate via gcloud: run `gcloud auth application-default login` in your terminal.
# 3. Uncomment the three lines below.
# 4. Replace YOUR_PROJECT_ID with your actual GCP Project ID.
# 5. Replace YOUR_LOCATION with your GCP region (e.g., us-central1).
#
# GOOGLE_GENAI_USE_VERTEXAI="True"
# GOOGLE_CLOUD_PROJECT="YOUR_PROJECT_ID"
# GOOGLE_CLOUD_LOCATION="YOUR_LOCATION"
#
# Optional: If using a service account key file instead of user ADC
# GOOGLE_APPLICATION_CREDENTIALS="/path/to/your/vertex-service-account-key.json"

EOF
echo "      .env template created."
echo ""
echo "      ******************************************************"
echo "      * CRITICAL: You MUST edit './${PROJECT_DIR}/.env' *"
echo "      *           before running the agent!              *"
echo "      ******************************************************"

echo "--- Project File Setup Complete ---"
echo

echo "====================================================="
echo " Setup Finished Successfully!"
echo "====================================================="
echo ""
echo " === ACTION REQUIRED: Configure and Run === "
echo ""
echo " 1. **Edit the '.env' File:**"
echo "    + Open the file './${PROJECT_DIR}/.env' in your editor (e.g., nano, vim, code)."
echo "      Command: nano ${PROJECT_DIR}/.env"
echo "    + Choose EITHER Option 1 (AI Studio Key) OR Option 2 (Vertex AI)."
echo "    + Uncomment the relevant lines for your chosen option."
echo "    + Replace placeholder values (API Key or Project ID/Location) with your actual details."
echo "    + Ensure the *other* option remains commented out (lines start with '#')."
echo "    + Save the file and exit the editor."
echo ""
echo " 2. **Activate Environment & Run ADK Web UI:**"
echo "    + Open a NEW terminal window/tab (or use your current one)."
echo "    + Activate the virtual environment:"
echo "      ==> source ${VENV_NAME}/bin/activate"
echo "    + Navigate to the PARENT directory created by this script:"
echo "      ==> cd ${PARENT_DIR_NAME}"
echo "    + Launch the ADK Development Web UI:"
echo "      ==> adk web"
echo ""
echo " 3. **Use the Agent in the Web UI:**"
echo "    + The 'adk web' command will output a URL (usually http://localhost:8000)."
echo "    + Open this URL in your web browser."
echo "    + In the top-left dropdown menu, select the agent: 'multi_tool_agent'."
echo "    + In the chat input box, try asking:"
echo "      - 'What time is it in New York?'"
echo "      - 'How's the weather in New York?'"
echo "      - 'What is the weather like in London?' (To test the agent's limitation)"
echo ""
echo " --- Troubleshooting ---"
echo "  - If 'multi_tool_agent' is not in dropdown: Ensure you ran 'adk web' from the './${PARENT_DIR_NAME}' directory (NOT inside '${AGENT_DIR_NAME}')."
echo "  - If API errors occur: Double-check your '.env' settings, ensure the correct section is active, API key/project ID is valid, and ADC is configured if using Vertex."
echo "  - Venv Activation: Remember to run 'source ${VENV_NAME}/bin/activate' in every new terminal session where you want to use 'adk' commands for this project."
echo "-----------------------------------------------------"

exit 0
