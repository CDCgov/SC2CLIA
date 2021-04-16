#!/usr/bin/env python3

from datetime import date, datetime, timedelta
import xml.etree.ElementTree as ET

def create_submission_xml(file_path, account, out_file, org_name = 'EDLB'):

    release_date = (date.today() + timedelta(days=2)).strftime("%Y-%m-%d")
    now = datetime.now().strftime("%Y-%m-%d_%H:%M")
    spuid_txt = f'{now}.{account}'  # must be unique for each submission

    root = ET.Element('Submission')

    elem1_des = ET.SubElement(root, 'Description')
    elem2_action = ET.SubElement(root, 'Action')

    elem1_1_comment = ET.SubElement(elem1_des, 'Comment')
    elem1_2_org = ET.SubElement(elem1_des, 'Organization')
    elem1_3_hold = ET.SubElement(elem1_des, 'Hold')

    elem1_1_comment.text = 'SARS-CoV-2 test submission'
    elem1_2_org.set('role', 'owner')
    elem1_2_org.set('type', 'center')
    elem1_3_hold.set('release_date', release_date)

    elem1_2_1_name = ET.SubElement(elem1_2_org, 'Name')
    elem1_2_1_name.text = org_name

    #Done with the elem1, elem2 starts here
    elem2_1_addfiles = ET.SubElement(elem2_action, 'AddFiles')
    elem2_1_addfiles.set('target_db', 'GenBank')

    elem2_1_1_file = ET.SubElement(elem2_1_addfiles, 'File')
    elem2_1_2_attr = ET.SubElement(elem2_1_addfiles, 'Attribute')
    elem2_1_3_ident = ET.SubElement(elem2_1_addfiles, 'Identifier')

    elem2_1_1_file.set('file_path', file_path)
    elem2_1_2_attr.set('name', 'wizard')
    elem2_1_2_attr.text = 'BankIt_SARSCoV2_api'

    elem2_1_1_1_datatype = ET.SubElement(elem2_1_1_file, 'DataType')
    elem2_1_3_1_spuid = ET.SubElement(elem2_1_3_ident, 'SPUID')

    elem2_1_1_1_datatype.text = 'genbank-submission-package'
    # account is the abbreviation provided during account creation.
    # This value will remain the same for every submission.
    elem2_1_3_1_spuid.set('spuid_namespace', account)
    elem2_1_3_1_spuid.text = spuid_txt

    xml = ET.tostring(root)
    with open(out_file, "wb") as f:
        f.write(xml)


if __name__ == "__main__":
    account = 'CDC-SC2CLIA'
    create_submission_xml('submission.zip', account, 'submission.xml')
