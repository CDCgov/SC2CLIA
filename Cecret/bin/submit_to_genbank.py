from ftplib import FTP
import datetime
__author__ = 'Mohit Thakur'
__version__ = '1.0'
__maintainer__ = 'Mohit Thakur'
__email__ = '***REMOVED***'
__status__ = 'Development'
# class Genbank_handler:
#     """Handler for the Genbank submission
#        Attributes:
#            hostname: String representing the sequence ID
#            seq_subs: String consisting of the amino acid substitutions
#            seq_sub_number: String value of how many substitutions there are
#            seq_dels: String consisting of amino acid deletions
#            seq_del_number: String value of how many deletions there are
#     """
#     pass
def login(ftp):
    ftp_response_message = ftp.login(user=user, passwd=passwd)
    print(ftp_response_message)
def changedir(ftp, dir):
    ftp_response_message = ftp.cwd(dir)
    print(ftp_response_message)
def uploadfiles(ftp, xml, zip, ready):
    for file in [xml, zip, ready]:
        myfile = open(file, 'rb')
        ftp_command = "STOR %s" % myfile
        # Transfer the file in binary mode
        ftp_response_message = ftp.storbinary(ftp_command, fp=myfile)
        print(ftp_response_message)
if __name__ == '__main__':
    # User input for password for CDC-SC2CLIA page
    passwd = input("Enter password:")
    # Login info
    host = 'ftp-private.ncbi.nlm.nih.gov'
    user = 'CDC-SC2CLIA'
    # Submission directory info
    subtype = "Test"  # Production
    now = datetime.datetime.now()
    ftpdir = "{}_{}".format(user, now.strftime("%Y.%m.%d-%H.%M.%S"))
    # print(ftpdir)
    # Files for upload
    xml = "submission.xml"
    zip = "submission.zip"
    submit = "submit.ready"
    with FTP(host) as genbank_ftp:
        login(genbank_ftp)
        changedir(genbank_ftp, subtype)
        # uploadfiles(genbank_ftp, xml, zip, submit)
