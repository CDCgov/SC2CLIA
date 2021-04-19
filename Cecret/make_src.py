import csv
import re
import sys
import ELIMS_metadata_ingest_gw_mo as gwmo
# ----------
#Csuid
#6786378-AJHDKJ-M0.fastq.gz
#4739284-SKDHMS-M0.fastq.gz
# How to add with ingest script
# Take in a file with csid/cuid/artfid
# csid = [str(4343242), str(4342342)]
# test_dict = gwmo.get_dict_NCBI_UPLOAD(csid)
# ---------
## Wrapper_for_upload
# python3 dict_to_csv.py sample_ids.txt > source_modifier.src
# python3 dict_to_csv.py sample_ids.txt > source_template.sbt
# Note, this will be placed under the code to pull the metadata from elims, and save the data into test_dict.

# Pull in "samples.txt"
## Example samples.txt
# 3002351197-N8KCQD6U
# 3002351198-N8KCQD6Z
# 3002351199-N8KCQD74

# with open("sample.txt", 'r') as openfile:
    # ID_DICT = dict()
    # for line in openfile:
        # split line [CSID, ARTIFACTID]
            #ID_DICT = {CSID: ARTIFACTID}

# csids=[map str() to ID_DICT.key()]
#for csid in csids:
    # valid_csids+=csid.checked()


csid=[str(3002228910), str(3002228998)]
test_dict=gwmo.get_dict_NCBI_UPLOAD(csid)



# test_dict = {'3031322614': {'Organism': 'Severe acute respiratory syndrome coronavirus 2', 'host': 'Homo sapien', 'collection-date': '11/03/2020', 'isolation-source': 'clinical', 'country': 'USA: KS'}, '3031324393': {'Organism': 'Severe acute respiratory syndrome coronavirus 2', 'host': 'Homo sapien', 'collection-date': '01/20/2021', 'isolation-source': 'clinical', 'country': 'USA: LA'}}
def print_header():
    print("sequence_ID\torganism\thost\tcollection_date\tisolation_source\tcountry")
    return "sequence_ID\torganism\thost\tcollection_date\tisolation_source\tcountry"
def print_row(key, val):
    sequence_ID = key
    Organism = val["Organism"]
    Host = val["host"]
    collection_date = val["collection-date"]
    collection_date = fix_collection_date(collection_date)
    Isolation_Source = val["isolation-source"]
    country = val["country"]
    if validate_sequenceid(sequence_ID) and validate_organism(Organism) and validate_host(Host) and validate_date(collection_date):
        # print("Success!")
        print("{0}\t{1}\t{2}\t{3}\t{4}\t{5}".format(sequence_ID, Organism, Host, collection_date, Isolation_Source, country))
        return "{0}\t{1}\t{2}\t{3}\t{4}\t{5}".format(sequence_ID, Organism, Host, collection_date, Isolation_Source, country)
    else:
        print("Failure")
def validate_sequenceid(sequence_id):
    if re.search('\d{10}|\w{8}', sequence_id):
        return True
    else:
        return False
def validate_organism(Organism):
    if Organism == "Severe acute respiratory syndrome coronavirus 2":
        return True
    else:
        return False
def validate_host(Host):
    if Host == "Homo sapien":
        return True
    else:
        return False
def validate_date(collection_date):
    if re.search('\d{4}-\d{2}-\d{2}', collection_date):
        return True
    else:
        return False
def validate_isolationsource(Isolation_Source):
    pass
def fix_collection_date(collection_date):
    date_list = collection_date.split("/")
    date_list.reverse()
    return "-".join(date_list)
if __name__ == "__main__":
    with open("output.csv", 'w') as f:
        w = csv.writer(f, delimiter='\t')
        header = print_header()
        w.writerow(header)
        for key, val in test_dict.items():
            row = print_row(key, val)
            # print(key, val)
            w.writerow(row)
