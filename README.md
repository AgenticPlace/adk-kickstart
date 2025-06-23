# augmentic 0.0.0
createse Augmentic Development Kit agent000

# Google ADK Agent Project Setup Script

## 🚀 Introduction

This Bash script automates the initial setup for a basic Google Agent Development Kit (ADK) agent project. It's designed to get you up and running quickly by:<br /><br />

1.  Creating a dedicated Python virtual environment.
2.  Installing the `google-adk` library and necessary dependencies (`tzdata`).
3.  Generating a standard directory structure for your ADK agent.
4.  Populating the structure with essential template files, including:
```txt
    *   `__init__.py`: To make the agent directory a Python package.
    *   `agent.py`: A sample multi-tool agent (Weather & Time for New York City) using `LlmAgent` and `FunctionTool`.
    *   `.env`: A template for configuring your Google API Key (for AI Studio) or Vertex AI settings.
```
The example agent is configured to provide weather and time information, but **only for New York City**, showcasing how to define tools and instruct the LLM.<br /><br />

## ✨ Features

*   **Automated Environment Setup:** Creates a Python virtual environment to isolate project dependencies.
*   **ADK Installation:** Installs `google-adk` and `tzdata` (for timezone support in the example agent).
*   **Project Scaffolding:** Generates a clean directory structure:
    ```
    .
    ├── augmentic_adk_env/      # Python virtual environment
    ├── adk_agent_project/      # Parent project directory
    │   └── multi_tool_agent/   # Agent-specific code
    │       ├── __init__.py
    │       ├── agent.py
    │       └── .env
    └── setup_adk_agent.sh      # This script
    ```
*   **Sample Agent Code:** Provides a working `agent.py` with:
    *   An `LlmAgent` (configured for `gemini-1.5-flash-latest`).
    *   Two `FunctionTool` examples: `get_weather` and `get_current_time`.
    *   Basic logging within the agent and tools.
    *   Clear instructions to the LLM about its capabilities and limitations (NYC only).
*   **Configuration Template:** Creates an `.env` template file with instructions for setting up API access via Google AI Studio API Key or Vertex AI.
*   **User-Friendly Prompts:** Guides the user through the setup process.

## 📋 Prerequisites

Before running this script, ensure you have the following installed on your system:

*   **Bash Shell:** (Standard on Linux and macOS, available on Windows via WSL or Git Bash).
*   **Python 3:** Version 3.8 or higher is recommended. The script uses `python3` command by default.
    *   The `venv` module must be available (usually included with Python 3).
*   **pip:** The Python package installer (usually comes with Python).
*   **Internet Connection:** Required to download packages from PyPI.

## ⚙️ Technical Explanation

### Script Breakdown

The script operates in two main phases:

1.  **Phase 1: Environment & Dependencies Setup**
    *   **Virtual Environment Creation:** Uses `python3 -m venv augmentic_adk_env` to create an isolated Python environment.
    *   **Activation (Subshell):** Activates the venv within the script's subshell to install packages into it.
    *   **Package Installation:** Installs `google-adk` and `tzdata` using `pip install --quiet`. `tzdata` is needed by `zoneinfo` for timezone lookups in the sample agent.
    *   **ADK Verification:** Runs `pip show google-adk` to confirm the installation (optional check).

2.  **Phase 2: Agent Project Files Creation**
    *   **Directory Structure:** Creates `./adk_agent_project/multi_tool_agent/` using `mkdir -p`.
    *   **`__init__.py`:** Creates an empty `__init__.py` file in the `multi_tool_agent` directory, making it a discoverable Python package for the ADK.
    *   **`agent.py`:** Populates `multi_tool_agent/agent.py` with a complete example:
        *   Imports necessary ADK components (`LlmAgent`, `FunctionTool`) and standard libraries (`datetime`, `logging`, `zoneinfo`).
        *   Sets up basic logging.
        *   Defines two tool functions:
            *   `get_weather(city: str)`: Simulates fetching weather for a city (hardcoded for "New York").
            *   `get_current_time(city: str)`: Simulates fetching the current time for a city using `zoneinfo` (hardcoded for "New York").
        *   Wraps these functions in `FunctionTool`.
        *   Defines a `root_agent` using `LlmAgent`, configured with:
            *   A name (`weather_time_agent`).
            *   A model (`gemini-1.5-flash-latest`).
            *   A description and specific instructions guiding the LLM's behavior, emphasizing its NYC-only capabilities.
            *   The list of defined tools.
    *   **`.env` Template:** Creates `multi_tool_agent/.env` with commented-out sections for:
        *   **Option 1:** Google AI Studio API Key (`GOOGLE_API_KEY`).
        *   **Option 2:** Vertex AI configuration (`GOOGLE_CLOUD_PROJECT`, `GOOGLE_CLOUD_LOCATION`).
        This file is crucial for authenticating with Google's generative AI services.

### Key Files Generated

*   `augmentic_adk_env/`: The Python virtual environment directory.
*   `adk_agent_project/multi_tool_agent/__init__.py`: Marks the `multi_tool_agent` directory as a Python package, allowing ADK to discover the agent defined within.
*   `adk_agent_project/multi_tool_agent/agent.py`: Contains the core logic of your ADK agent. The provided template demonstrates how to define tools, configure an LLM agent, and set its behavior.
*   `adk_agent_project/multi_tool_agent/.env`: Stores sensitive configuration like API keys and project IDs. **This file should be added to `.gitignore` if you are using version control.**

## 🛠️ Usage

1.  **Download the Script:**
    Save the script content to a file, for example, `setup_adk_agent.sh`.

2.  **Make it Executable:**
    Open your terminal and navigate to the directory where you saved the script.
    ```bash
    chmod +x setup_adk_agent.sh
    ```

3.  **Run the Script:**
    ```bash
    ./setup_adk_agent.sh
    ```
    The script will display what it intends to do and ask for confirmation before proceeding.

4.  **❗ CRITICAL: Configure `.env` File ❗**
    After the script finishes, you **MUST** configure the API access:
    *   Navigate to the agent directory:
        ```bash
        cd adk_agent_project/multi_tool_agent
        ```
    *   Open the `.env` file in a text editor (e.g., `nano .env`, `vim .env`, or using VS Code).
    *   **Choose ONE option:**
        *   **Option 1 (AI Studio API Key):**
            1.  Get an API key from [Google AI Studio](https://aistudio.google.com/app/apikey).
            2.  Uncomment the lines for `GOOGLE_GENAI_USE_VERTEXAI="False"` and `GOOGLE_API_KEY`.
            3.  Replace `PASTE_YOUR_ACTUAL_API_KEY_HERE` with your actual key.
        *   **Option 2 (Vertex AI):**
            1.  Ensure you have a Google Cloud Project with the Vertex AI API enabled.
            2.  Authenticate your local environment: `gcloud auth application-default login`.
            3.  Uncomment the lines for `GOOGLE_GENAI_USE_VERTEXAI="True"`, `GOOGLE_CLOUD_PROJECT`, and `GOOGLE_CLOUD_LOCATION`.
            4.  Replace `YOUR_PROJECT_ID` and `YOUR_LOCATION` (e.g., `us-central1`) with your details.
    *   **Ensure the other option remains commented out.**
    *   Save and close the `.env` file.

5.  **Activate Virtual Environment & Run ADK Web UI:**
    *   Open a **new** terminal window/tab or use your current one.
    *   Activate the virtual environment:
        ```bash
        source augmentic_adk_env/bin/activate
        ```
        *(Your terminal prompt should now be prefixed with `(augmentic_adk_env)`)*
    *   Navigate to the **parent project directory** (the one *containing* `multi_tool_agent`):
        ```bash
        cd adk_agent_project
        ```
        *(If you are already in `adk_agent_project/multi_tool_agent`, go up one level: `cd ..`)*
    *   Launch the ADK Development Web UI:
        ```bash
        adk web
        ```

6.  **Use the Agent in the Web UI:**
    *   The `adk web` command will output a URL, usually `http://localhost:8000`.
    *   Open this URL in your web browser.
    *   In the top-left dropdown menu, you should see and be able to select the agent: `multi_tool_agent`.
    *   Try interacting with the agent in the chat input box:
        *   "What time is it in New York?"
        *   "How's the weather in New York?"
        *   "What is the weather like in London?" (This will test the agent's stated limitation)

## 📝 Summary

This script provides a convenient way to bootstrap a Google ADK project with a functional, albeit simple, example agent. It handles the creation of the virtual environment, installation of ADK, and generation of boilerplate code, allowing you to focus on developing your agent's logic and tools.

The generated agent demonstrates:
*   Using `LlmAgent` with a specified Gemini model.
*   Defining tools using `FunctionTool`.
*   Instructing the agent on how and when to use its tools, and its limitations.
*   Basic logging for debugging.

## 🔧 Customization & Next Steps

*   **Modify `agent.py`:**
    *   Change the `model` in `LlmAgent` to other compatible Gemini models (e.g., `gemini-pro`).
    *   Update the `description` and `instruction` for the agent.
    *   Add new tools by defining Python functions and wrapping them with `FunctionTool`.
    *   Implement actual API calls in your tool functions (e.g., use a real weather API instead of the simulation).
    *   Remove the "New York only" limitation by making your tools more robust.
*   **Explore ADK Features:** Dive deeper into the [Google ADK documentation](https://developers.google.com/agent-platform/adk) to learn about more advanced features like agent composition, state management, and different tool types.
*   **Version Control:** Initialize a Git repository in your `adk_agent_project` directory and remember to add `augmentic_adk_env/` and `adk_agent_project/multi_tool_agent/.env` to your `.gitignore` file.

## 🔍 Troubleshooting

*   **`ModuleNotFoundError` or `command not found: adk`:**
    Ensure your virtual environment (`augmentic_adk_env`) is activated: `source augmentic_adk_env/bin/activate`.
*   **Agent `multi_tool_agent` not found in `adk web` UI dropdown:**
    Make sure you are running `adk web` from the `adk_agent_project` directory (the parent directory of `multi_tool_agent`), not from inside `multi_tool_agent` itself.
*   **API Errors / Authentication Issues (e.g., 401, 403, permission denied):**
    *   Double-check your `adk_agent_project/multi_tool_agent/.env` file.
    *   Ensure only ONE option (AI Studio Key or Vertex AI) is uncommented and correctly filled.
    *   Verify your API key is valid and has the necessary permissions.
    *   If using Vertex AI, confirm your `gcloud auth application-default login` was successful and your project/location are correct.
    *   Ensure the Vertex AI API is enabled in your GCP project.
*   **"Failed to create virtual environment"**:
    *   Ensure `python3` is correctly installed and in your PATH.
    *   Ensure the `venv` module is available for your Python 3 installation. You might need to install it separately depending on your OS/Python distribution (e.g., `sudo apt install python3-venv` on Debian/Ubuntu).
*   **`tzdata` or `zoneinfo` issues:**
    The script installs `tzdata`. If you still encounter issues with `ZoneInfo`, ensure your system has timezone data accessible. This is usually not a problem on modern systems.

---

Happy Agent Building!
