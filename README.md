### A2I2 T2 2023 (GPT vs Stack Overflow: data collection)

This repo can be used to create a dataset of Stack Overflow (SO) questions with corresponding:
- SO accepted answers
- SO metadata (e.g. score, tags, etc)
- GPT-4 answers (via OpenAI API)
- GPT-4 evaluation between the human and GPT answer (via OpenAI evals)

This dataset can then be used for further research in evaluating GPT vs human performance within the context of the programming questions provided by Stack Overflow.

Code is split across multiple files:
1.  `mysql_data_extraction.ipynb` pulls SO data and export it into a CSV file called `saved_dataset.csv`. This file feeds into both `data_analysis.ipynb` and `data_processing.ipynb`.
2. `data_analysis.ipynb` performs some rudimentary data analysis on the raw dataset provided. Running it is optional, as it runs independently of the data processing step. It will read from `tag_count.csv`, or generate this file by counting the quantity of tags found in `saved_dataset.csv` if it does not already exist.
3. `data_processing.ipynb` runs OpenAI and evals queries, and performs all necessary data processing and pre-processing to do so.

`bigquery_data_extraction.ipynb` is an alternative way of pulling SO data and generating the corresponding `saved_dataset.csv` file using Google BigQuery instead of a local database. It is considered legacy code and not recommended for serious use because the BigQuery SO dataset has evidently not been keeping up with its planned quarterly dataset update. Note also that the database query in this file differs slightly due to the file's legacy status. 

#### Usage Instructions

1. Acquire the `saved_dataset.csv` file and have it in the root directory. Ths easy way to get this file is to use our provided copy <TODO: add link here>. Alternatively, generate the file yourself using ONE of the two methods outlined below.
2. Put your [OpenAI API key](https://platform.openai.com/account/api-keys) in the secrets.json file (secrets_example.json is provided for reference).
3. Install [Git Large File Storage](https://git-lfs.com/), which is required by evals.
4. Optionally run `data_analysis.ipynb`.
5. In the root directory, the following folders currently need to be created manually: `eval_logs`, `eval_records`, `eval_samples`.
6. Run `data_processing.ipynb`

Please note that `data_processing.ipynb` forcefully re-clones the evals installation each time it runs (i.e., it deletes / overwrites existing evals files). If you want to avoid this from happening, you can comment out the relevant lines after the notebook has been run for the first time.

#### SO Dataset creation - Stack Exchange Data Dump

_This step is only required if you want to generate the raw SO dataset yourself using the Stack Exchange Data Dump instead of using our provided copy._
1. Download the Stack Overflow archives from the [Stack Exchange Data Dump](https://archive.org/details/stackexchange) (BitTorrent is recommended for speed reasons). Each Stack Exchange website has its own set of archives.
2. Extract the downloaded 7z archives. Inside are some **enormous** XML files.
3. On a system with MySQL installed ([example installation instructions for Windows](https://www.w3schools.com/mysql/mysql_install_windows.asp)) use `a2i2_stackexchange_data_dump_import_v3.sql` (e.g., in MySQL Workbench if you followed the previously linked instructions) to import the XML files into a database. The script uses absolute file paths, so you'll need to update the paths to point to where you have your XML files stored. Note for MySQL version >= 8 you may need to set `secure-file-priv=""` (in e.g., the my.ini config file), or alternatively place your XML files in the default path for that setting.
4. Set the appropriate server/user details in `mysql_data_extraction.ipynb`, then run at least the first half of the notebook (the cutoff point is clearly marked in the file). This will generate the `saved_dataset.csv` file. (The second half is not required, but demonstrates a quirk with pandas' default CSV export/import settings with regard to the `creation_date` column in our dataframe.) 

Note that in this process, there are additional, unused files being downloaded and imported into the database. If you are not using the information in these files in any way, you may optionally choose to not download these extra files, and modify the database import script to not include these files in your database.

#### SO Dataset creation - Google BigQuery

_This step is only required if you want to generate the raw SO dataset yourself using Google BigQuery instead of using our provided copy. Doing this is not recommended due to the age of the BigQuery dataset!_

1. Setup authentication for the Google BigQuery API, such as by having [user credentials in the local environment](https://cloud.google.com/docs/authentication/provide-credentials-adc#local-user-cred).
2. Create a BigQuery project (e.g. via BigQuery web interface). Put the project name in the secrets.json file (secrets_example.json is provided for reference).
3. Run `bigquery_data_extraction.ipynb`. This will generate the `saved_dataset.csv` file.

#### Troubleshooting

- In our experience evals can be _extremely_ fussy about the environment it's installed in. If having problems with evals, consider creating a new, minimal Python environment (without additional packages installed on creation).
- There are several implicit dependencies in the notebooks (e.g., pandas, numpy, etc). This may be relevant if using a new, minimal Python environment to avoid the wrath of evals. Because the packages installed in the notebook share these dependencies, you should be able to handle the implicit dependencies by manually separating out any `%pip install ` commands and running them before running each of the notebooks proper.
- In some environments, evals will (for unknown reasons) not recognize a valid, working OpenAI API key as existing. In this case, you can spoonfeed the API key in-line with the evals query itself e.g.: `!export OPENAI_API_KEY="ab-cd123"; openaieval gpt-3.5-turbo coqa-fact"`

#### License
<TODO: license>
<TODO: unless license is MIT, the database import script should be separately licensed with MIT>

#### Credits
- The MySQL database import script was created by Georgios Gousios, with additional contributions by tundo91, Roel Van de Paar (RoelVdP), and myself (Mark Heath / MHLoppy). It is available under the MIT (Expat) License.
- My code builds on prior work at the Applied Artificial Intelligence Institute (A2I2) by [Gia Phu Tran (Harvey)](https://github.com/phulelouch).
- Special thanks to everyone at A2I2 who contributed to my work, particularly my supervisors Anj Simmons and Zafaryab Rasool.