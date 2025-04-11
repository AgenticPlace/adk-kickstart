#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

# --- Configuration ---
VENV_NAME="augmentic"
PARENT_DIR_NAME="parent_folder" # Name for the directory containing the agent
AGENT_DIR_NAME="multi_tool_agent" # Name for the agent module directory
PROJECT_DIR="${PARENT_DIR_NAME}/${AGENT_DIR_NAME}" # Combined path
PYTHON_CMD="python3" # Use python3 for clarity, adjust if needed

# --- Script Start ---
echo "Starting ADK Agent Setup (Weather/Time Example)..."
echo "-----------------------------------------------------"

# 1. Create & Activate Virtual Environment (within script scope)
echo "1. Creating Python virtual environment './${VENV_NAME}'..."
if ! ${PYTHON_CMD} -m venv ${VENV_NAME}; then
    echo "ERROR: Failed to create virtual environment. Ensure Python 3 and venv are installed."
    exit 1
fi

echo "   Activating virtual environment for installation..."
# Activate within the script's subshell to install packages into it
source ${VENV_NAME}/bin/activate

# Install ADK
echo "2. Installing google-adk package..."
if ! pip install google-adk; then
    echo "ERROR: Failed to install google-adk. Check pip and network connection."
    exit 1
fi
echo "   google-adk installed successfully."

# Optional: Verify installation
echo "   Verifying installation..."
pip show google-adk | grep Version

# Deactivate (script's subshell activation ends anyway)
# deactivate

echo "-----------------------------------------------------"
# 2. Create Agent Project Structure
echo "3. Creating project structure './${PROJECT_DIR}'..."
mkdir -p ${PROJECT_DIR}
echo "   Project directory created."

echo "4. Creating '__init__.py'..."
echo "from . import agent" > ${PROJECT_DIR}/__init__.py
echo "   __init__.py created."

echo "5. Creating 'agent.py'..."
# Use cat with heredoc for multi-line content
cat << 'EOF' > ${PROJECT_DIR}/agent.py
import datetime
import logging
from zoneinfo import ZoneInfo
# Use LlmAgent as the base for models like Gemini
from google.adk.agents import LlmAgent
from google.adk.tools import FunctionTool

# Setup basic logging for visibility inside the agent/tools
logging.basicConfig(level=logging.INFO)
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
    if city.lower() == "new york":
        return {
            "status": "success",
            "report": (
                "The weather in New York is sunny with a temperature of 25 degrees"
                " Celsius (41 degrees Fahrenheit)."
            ),
        }
    else:
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
    if city.lower() == "new york":
        tz_identifier = "America/New_York"
    else:
        return {
            "status": "error",
            "error_message": (
                f"Sorry, I don't have timezone information for {city}."
            ),
        }

    try:
        # ZoneInfo requires the 'tzdata' package on some systems
        # Add 'pip install tzdata' to dependencies if needed
        tz = ZoneInfo(tz_identifier)
        now = datetime.datetime.now(tz)
        report = (
            f'The current time in {city} is {now.strftime("%Y-%m-%d %H:%M:%S %Z%z")}'
        )
        return {"status": "success", "report": report}
    except Exception as e:
        logger.error(f"Error in get_current_time: {e}", exc_info=True)
        return {"status": "error", "error_message": f"Error getting time for {city}: {e}"}

# Explicitly wrap functions in FunctionTool
tools_list = [
    FunctionTool(func=get_weather),
    FunctionTool(func=get_current_time)
]

# Define the root agent using LlmAgent
root_agent = LlmAgent(
    name="weather_time_agent",
    # Ensure model name is current and accessible
    model="gemini-1.5-flash-latest", # Or "gemini-pro" or other compatible model
    description=(
        "Agent to answer questions about the time and weather in New York City."
    ),
    instruction=(
        "You can answer questions about the current time and weather, but ONLY for New York City. "
        "Use the available tools ('get_weather', 'get_current_time') to get the information when asked."
        "Politely state that you cannot provide information for other cities."
    ),
    tools=tools_list,
)

logger.info(f"ADK Agent '{root_agent.name}' defined in agent.py")

# Note: To run this agent, you typically need an entry point that uses
# google.adk.runners.Runner, which is often handled by 'adk web' or 'adk run'.
EOF
echo "   agent.py created."

echo "6. Creating '.env' file (template)..."
cat << 'EOF' > ${PROJECT_DIR}/.env
# --- .env Configuration ---
# Instructions: Uncomment and fill ONLY ONE section below (either Option 1 OR Option 2).
# Ensure you replace placeholder values with your actual credentials/project info.
# Make sure there are no leading/trailing spaces around the '=' sign.

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
echo "   .env file created. **CRITICAL: You MUST edit this file before running the agent!**"

echo "-----------------------------------------------------"
echo " Initial Setup Complete!"
echo "-----------------------------------------------------"
echo ""
echo " === ACTION REQUIRED: Configure and Run === "
echo ""
echo " 1. **Edit the '.env' File:**"
echo "    Open the file './${PROJECT_DIR}/.env' in a text editor:"
echo "    ==> nano ${PROJECT_DIR}/.env"
echo "    - Choose EITHER Option 1 (AI Studio Key) OR Option 2 (Vertex AI)."
echo "    - Uncomment the lines for your chosen option."
echo "    - Replace placeholder values (API Key or Project ID/Location) with your actual details."
echo "    - Ensure the *other* option remains commented out."
echo "    - Save and exit (Ctrl+X, then Y, then Enter in nano)."
echo ""
echo " 2. **Activate Environment & Run Agent:**"
echo "    Open a NEW terminal or use your current one, then run:"
echo ""
echo "    # Activate the virtual environment:"
echo "    source ${VENV_NAME}/bin/activate"
echo ""
echo "    # Navigate to the PARENT directory:"
echo "    cd ${PARENT_DIR_NAME}"
echo ""
echo "    # Launch the ADK Web UI:"
echo "    adk web"
echo ""
echo " 3. **Use the Agent:**"
echo "    - Open the URL provided by 'adk web' (usually http://localhost:8000) in your browser."
echo "    - Select 'multi_tool_agent' from the agent dropdown."
echo "    - Try asking: 'What time is it in New York?' or 'How is the weather in New York?'"
echo "    - Ask about another city to see the refusal message."
echo ""
echo " --- Troubleshooting ---"
echo "  - If 'multi_tool_agent' is missing: Make sure you ran 'adk web' from './${PARENT_DIR_NAME}'."
echo "  - If API errors occur: Double-check your '.env' configuration and ADC authentication."
echo "  - Remember to activate the venv ('source ${VENV_NAME}/bin/activate') in every new terminal."
echo "-----------------------------------------------------"

exit 0
