# A2I2 T2 2023 - GPT vs Stack Overflow: data collection

This repo can be used to create a large dataset of Stack Overflow (SO) questions with corresponding:
- SO accepted answers
- SO metadata (e.g. score, tags, etc)

From here, a random subsample is chosen, and the following are added to this subsample:
- GPT-4 answers (via OpenAI API)
- GPT-4 evaluation between the human and GPT answer (via OpenAI evals)

This can then be used for further research in evaluating GPT vs human performance within the context of the programming questions provided by Stack Overflow.

## Dataset download

[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.8403468.svg)](https://doi.org/10.5281/zenodo.8403468)

**>>> The associated dataset with this repo is available [here](https://doi.org/10.5281/zenodo.8403468). <<<**

## File overview

Code is split across multiple files:
1.  `mysql_data_extraction.ipynb` pulls SO data and exports it into a CSV file called `saved_dataset.csv`. This file feeds into both `dd_dataset_analysis.ipynb` and `data_processing.ipynb`.
2. `dd_dataset_analysis.ipynb` performs some rudimentary data analysis on the raw dataset provided. Running it is optional, as it runs independently of the data processing step. It will read from `tag_count.csv`, or generate this file if it doesn't already exist by counting the quantity of tags found in `saved_dataset.csv`.
3. `data_processing.ipynb` runs OpenAI and evals queries, and performs all necessary data processing and pre-processing to do so.

`bigquery_data_extraction.ipynb` is an alternative way of pulling SO data and generating the corresponding `saved_dataset.csv` file using Google BigQuery instead of a local database. `bq_dataset_analysis` can then be used to perform rudimentary analysis on the dataset. These are considered legacy code and are not recommended for serious use because the BigQuery SO dataset has evidently not been keeping up with its planned quarterly dataset update. Note also that the database query in this file differs slightly due to the file's legacy status. 

## Usage Instructions

1. Acquire the `saved_dataset.csv` file and have it in the root directory. The easy way to get this file is to use our provided copy (download and extract `DD_saved_dataset.zip` from the DOI above). Alternatively, generate the file yourself using ONE of the two methods outlined below.
2. Put your [OpenAI API key](https://platform.openai.com/account/api-keys) in a `secrets.json` file in the root directory (`secrets_example.json` is provided for reference).
3. Install [Git Large File Storage](https://git-lfs.com/), which is required by evals.
4. Optionally run `dd_dataset_analysis.ipynb`. This will generate some stats and charts in the notebook's output, plus save `tag_count.csv` to file if one doesn't already exist.
5. In the root directory, the following folders currently need to be created manually: `eval_logs`, `eval_records`, `eval_samples`.
6. Run `data_processing.ipynb`. This will generate the `dataset_results.csv` file.

### Usage notes

- Please note that `data_processing.ipynb` forcefully re-clones the evals installation each time it runs (i.e., it deletes / overwrites existing evals files). It also generates new JSONL sample files (used by evals), overwriting previously generated files. If you want to avoid this from happening, you can comment out the relevant lines after the notebook has been run for the first time.
- The model used is GPT-4, but this shoud be relatively easy to change to a different OpenAI model.
- The default size of the dataset subsampling is 10, which is intentionally small so as to not burn credit when testing the file. It can be changed to any arbitrary number or percentage.
- HTML tags are stripped from all text prior to using the text in both the OpenAI API and evals. This includes the GPT response received. The original (unstripped) and stripped versions of the relevant fields are saved in separate columns in the dataframe.
- Token limits have been semi-arbitrarily set at 4K for the combined SO title, question, and accepted answer, and 2K for the GPT response. With GPT-4's token limit of ~8K, this leaves roughly 2K for the evaluation response.
- After initial pre-processing, the main dataframe is broken into chunks in order to perform both OpenAI API requests and evaluations in batches. The default number of chunks is 10, but this is arbitrary and can be changed (although see below).
- **The way that rows are skipped when the token limits are reached and how they're subsequently handled is not very robust, and may lead to undesirable or unexpected behaviour if batch size does not equal subsample size.** For sufficiently large subsamples, it's possible that it may still not play nicely even if batch size DOES equal subsample size. This is due to quirks in a tiny minority of questions or answers being data processing minefields.
- No new eval is registered and used by evals in this code. Instead, the default `coqa-fact` eval is repurposed by replacing the `samples.jsonl` file it uses.

### SO Dataset creation - Stack Exchange Data Dump

_This step is only required if you want to generate the raw SO dataset yourself using the Stack Exchange Data Dump instead of using our provided copy._
1. Download the Stack Overflow archives from the [Stack Exchange Data Dump](https://archive.org/details/stackexchange) (BitTorrent is recommended for speed reasons). Each Stack Exchange website has its own set of archives.
2. Extract the downloaded 7z archives. Inside are some **enormous** XML files.
3. On a system with MySQL installed ([example installation instructions for Windows](https://www.w3schools.com/mysql/mysql_install_windows.asp)) use `a2i2_stackexchange_data_dump_import_v3.sql` (e.g., in MySQL Workbench if you followed the previously linked instructions) to import the XML files into a database. The script uses absolute file paths, so you'll need to update the paths to point to where you have your XML files stored. Note for MySQL versions >= 8 you may need to set `secure-file-priv=""` (in e.g., the `my.ini` config file), or alternatively place your XML files in the default path for that setting.
4. Set the appropriate server/user details in `mysql_data_extraction.ipynb`, then run at least the first half of the notebook (the cutoff point is clearly marked in the file). This will generate the `saved_dataset.csv` file. (The second half is not required, but demonstrates a quirk with pandas' default CSV export/import settings with regard to the `creation_date` column in our dataframe.) 

Note that in this process, there are additional, unused files being downloaded and imported into the database. If you are not using the information in these files in any way, you may optionally choose to not download these extra files, and modify the database import script to not include these files in your database.

### SO Dataset creation - Google BigQuery

_This step is only required if you want to generate the raw SO dataset yourself using Google BigQuery instead of using our provided copy. Doing this is not recommended due to the age of the BigQuery dataset!_

1. Set up authentication for the Google BigQuery API, such as by having [user credentials in the local environment](https://cloud.google.com/docs/authentication/provide-credentials-adc#local-user-cred).
2. Create a BigQuery project (e.g. via the BigQuery web interface). Put the project name in a `secrets.json` file in the root directory (`secrets_example.json` is provided for reference).
3. Run `bigquery_data_extraction.ipynb`. This will generate the `saved_dataset.csv` file.

## Troubleshooting

- In our experience, evals can be _extremely_ fussy about the environment it's installed in. If having problems with evals, consider creating a new, minimal Python environment (without additional packages installed on creation).
- There are several implicit dependencies in the notebooks (e.g., pandas, numpy, etc). This may be relevant if using a new, minimal Python environment to avoid the wrath of evals. Because the packages installed in the notebook share these dependencies, you should be able to handle the implicit dependencies by manually separating out any `%pip install ` commands and running them before running each of the notebooks proper.
- In some environments, evals will (for unknown reasons) not recognize a valid, working OpenAI API key as existing. In this case, you can spoonfeed the API key in-line with the evals query itself e.g.: `!export OPENAI_API_KEY="ab-cd123"; openaieval gpt-3.5-turbo coqa-fact"`

## License
Code available under MIT License (Expat License).

The associated dataset is licensed under [CC BY-SA 4.0 license](https://creativecommons.org/licenses/by-sa/4.0/).

## Credits
- The MySQL database import script was created by Georgios Gousios, with additional contributions by tundo91, Roel Van de Paar (RoelVdP), and myself (Mark Heath / MHLoppy). It is available under the MIT (Expat) License.
- My code builds on prior work at the Applied Artificial Intelligence Institute (A2I2) by [Gia Phu Tran (Harvey)](https://github.com/phulelouch).
- Special thanks to everyone at A2I2 who assisted in my efforts, particularly my supervisors Anj Simmons and Zafaryab Rasool.
