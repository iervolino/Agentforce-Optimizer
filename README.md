# Agentforce Optimizer

Agentforce Optimizer is a Salesforce DX project that helps validate and enhance Agentforce configurations to improve agent performance. It checks your setup against best practices across topics, instructions, and actions, and offers tailored recommendations for optimization.

# 🔍 What It Does

This tool automates the validation and optimization process for Agentforce configurations (Topics, Instructions and Actions).

Key capabilities include:

- Verifying configurations against best practices
- Highlighting potential issues and opportunities for optimization

# 🛠️ How It Works
The project leverages a configurable Prompt Template (named Validate Agentforce Configurations) available through Prompt Builder. This template drives the validation logic and can be extended to support evolving use cases or business requirements.

# ⚠️ Note
The current version of the Optimizer leverages the custom GenAIMetadataServiceRetriever to retrieve agent configurations. At this stage, it is limited to fetching custom topics that include associated instructions and actions, with the action data restricted to the action name only.

## Prerequisites

- Salesforce CLI (sfdx)
- Salesforce DX project structure
- Access to a Salesforce org with Agentforce capabilities

## Getting Started

1. Clone this repository
   ```bash
   git clone https://github.com/iervolino/Agentforce-Optimizer.git
   cd Agentforce-Optimizer
   ```
2. Authenticate with your Salesforce org:
   ```bash
   sfdx auth:web:login
   ```
3. Deploy the project to your org:
   ```bash
   sfdx project:deploy:start
   ```

## Development

This project uses the Salesforce DX development model. For more information about development models, see the [Salesforce DX Developer Guide](https://developer.salesforce.com/docs/atlas.en-us.sfdx_dev.meta/sfdx_dev/sfdx_dev_intro.htm).

## Configuration

The `sfdx-project.json` file contains the project configuration, including:
- Package name: Agentforce_Optimizer
- Version: 0.1.0
- API Version: 63.0

## Resources

- [Salesforce Extensions Documentation](https://developer.salesforce.com/tools/vscode/)
- [Salesforce CLI Setup Guide](https://developer.salesforce.com/docs/atlas.en-us.sfdx_setup.meta/sfdx_setup/sfdx_setup_intro.htm)
- [Salesforce DX Developer Guide](https://developer.salesforce.com/docs/atlas.en-us.sfdx_dev.meta/sfdx_dev/sfdx_dev_intro.htm)
- [Salesforce CLI Command Reference](https://developer.salesforce.com/docs/atlas.en-us.sfdx_cli_reference.meta/sfdx_cli_reference/cli_reference.htm)

## Contributing

1. Create a feature branch
2. Make your changes
3. Submit a pull request

## License

MIT License

Copyright (c) 2025 

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
