A2I2 T2 2023 - Stack Overflow: human vs AI answers.

Additional requirements to run code successfully:
- There are several(common) dependencies which are not explicitly dealt with, such as git, pandas, and numpy.
- Evals requires [Git Large File Storage](https://git-lfs.com/) to be installed (installation seems to have OS-specific elements, so is hard to do programatically).
- Authentication for Google BigQuery API, such as by having [user credentials in the local environment](https://cloud.google.com/docs/authentication/provide-credentials-adc#local-user-cred).
- BigQuery project name and [OpenAI API key](https://platform.openai.com/account/api-keys) placed in secrets.json file (secrets_example.json is provided for reference).

Notes:
- In some environments, evals will (for unknown reasons) not recognize a valid, working OpenAI API key as existing. In this case, you can spoonfeed the API key in-line with the evals query itself e.g.: `!export OPENAI_API_KEY="ab-cd123"; openaieval gpt-3.5-turbo coqa-fact"`
- If using a saved copy an already-run BigQuery query, authentication is probably not required, and the project name in secrets.json probably isn't either. You should be able to get away with just having the relevant libraries installed without any extra steps needed.
