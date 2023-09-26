A2I2 T2 2023 - Stack Overflow: human vs AI answers.

Code is split across multiple files:
1. First, choose to source data from either Google BigQuery or from a database created using Stack Exchange Data Dump files.
    - If using BigQuery, run `bigquery_data_extraction.ipynb`. <TODO> note that the query is slightly different (legacy code)
    - If using SEDD, first set up a local MySQL database, such as using [these instructions for Windows](https://www.w3schools.com/mysql/mysql_install_windows.asp). Download the SEDD files relating to Stack Overflow (BitTorrent is recommended for speed) and extract them. Run the <TODO> script in your database program (e.g., MySQL Workbench) to create the database. Note that the script will need to be updated to have the correct file paths to the extracted SEDD files. TODO: note that not EVERYTHING there is strictly needed (could download less files, import less files, and then have a smaller database).
2. Optionally run <TODO> for basic dataset analysis and visualizations.
3. Lastly, run <TODO> which will handle data pre-processing, fetching GPT answers, and running evals.

Additional requirements to run code successfully:
- There are several(common) dependencies which are not explicitly dealt with, such as git, pandas, and numpy.
- Evals requires [Git Large File Storage](https://git-lfs.com/) to be installed (installation seems to have OS-specific elements, so is hard to do programatically).
- Authentication for Google BigQuery API, such as by having [user credentials in the local environment](https://cloud.google.com/docs/authentication/provide-credentials-adc#local-user-cred).
- BigQuery project name and [OpenAI API key](https://platform.openai.com/account/api-keys) placed in secrets.json file (secrets_example.json is provided for reference).
- In the root directory, the following folders currently need to be created manually: `eval_logs`, `eval_records`, `eval_samples`.

Notes:
- In some environments, evals will (for unknown reasons) not recognize a valid, working OpenAI API key as existing. In this case, you can spoonfeed the API key in-line with the evals query itself e.g.: `!export OPENAI_API_KEY="ab-cd123"; openaieval gpt-3.5-turbo coqa-fact"`
- If using a saved copy an already-run BigQuery query, authentication is probably not required, and the project name in secrets.json probably isn't either. You should be able to get away with just having the relevant libraries installed without any extra steps needed.
