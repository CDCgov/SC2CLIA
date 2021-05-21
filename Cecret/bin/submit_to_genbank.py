from ftplib import FTP
import datetime
import os
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
def login(ftp, user, password):
    """
    Logs into a remote host using a username and password
    :param ftp: ftplib object
    :param user: String of username
    :param password: String of password
    :return: None
    """
    ftp_response_message = ftp.login(user=user, passwd=password)
    print(ftp_response_message)
def make_subdir(ftp, subtype, subdir):
    """
    Makes a subdirectory, after changing directory into
    the proper submission type
    :param ftp:  ftplib object
    :param subtype: String {Test / Production}
    :param subdir: String of new directory to make
    :return: None
    """
    ftp_response_message = ftp.cwd(subtype)
    print(ftp_response_message)
    ftp_response_message = ftp.dir()
    print(ftp_response_message)
    ftp_response_message = ftp.mkd(subdir)
    print(ftp_response_message)
    ftp_response_message = ftp.cwd(subdir)
    print(ftp_response_message)
    ftp_response_message = ftp.dir()
    print(ftp_response_message)
def upload_files(ftp, **kwargs):
    """
    Upload files to server
    :param ftp: ftplib object
    :param kwargs: all files to submit
    :return:
    """
    for file in kwargs:
        myfile = open(kwargs[file], 'rb')
        ftp_command = "STOR %s" % myfile
        # Transfer the file in binary mode
        ftp_response_message = ftp.storbinary(ftp_command, fp=myfile)
        print(ftp_response_message)
if __name__ == '__main__':
    # Login info
    host = 'ftp-private.ncbi.nlm.nih.gov'
    user = 'CDC-SC2CLIA'
    password = input("Enter password:")
    # Submission directory info
    subtype = "Test"  # Production
    now = datetime.datetime.now()
    subdir = "{}_{}".format(user, now.strftime("%Y.%m.%d-%H.%M.%S"))
    # Files for upload (assume in upload directory)
    xml_file = "submission.xml"
    zip_file = "submission.zip"
    submit_file = "submit.ready"
    with FTP(host) as genbank_ftp:
        login(genbank_ftp, user, password)
        make_subdir(genbank_ftp, subtype, subdir)
        upload_files(genbank_ftp, xml=xml_file, zip=zip_file)#, submit=submit_file)
