from ftplib import FTP, all_errors
import datetime
import logging
import sys
# Change logging level
logging.basicConfig(level=logging.DEBUG)
logger = logging.getLogger('BasicLogger')
__author__ = 'Mohit Thakur'
__version__ = '1.1'
__maintainer__ = 'Mohit Thakur'
__email__ = '***REMOVED***'
__status__ = 'Development'
def login(ftp, user, password):
    """
    Logs into a remote host using a username and password
    :param ftp: ftplib object
    :param user: String of username
    :param password: String of password
    :return: None
    """
    try:
        response = ftp.login(user=user, passwd=password)
        logger.info(response)
    except all_errors as e:
        # @ToDo Save the error in the database
        sys.exit("Password is incorrect")
def change_dir(ftp, dir):
    """
    Makes a subdirectory, after changing directory into
    the proper submission type
    :param ftp:  ftplib object
    :param dir: String directory to change to
    :return: None
    """
    try:
        response = ftp.cwd(dir)
        logger.info(response)
    except all_errors as e:
        # @ToDo Save the error in the database
        sys.exit("Cannot change to submission directory")
def make_subdir(ftp, subdir):
    """
    Makes a subdirectory, after changing directory into
    the proper submission type
    :param ftp:  ftplib object
    :param subdir: String of new directory to make
    :return: None
    """
    try:
        response = ftp.mkd(subdir)
        logger.info(response)
    except all_errors as e:
        # @ToDo Save the error in the database
        sys.exit("Cannot create submission directory")
def upload_file(ftp, file):
    """
    Upload files to server
    :param ftp: ftplib object
    :param file: the files to submit
    :return: None
    """
    try:
        with open(file, 'rb') as up_file:
            response = ftp.storbinary('STOR ' + file, up_file)
            logger.info(response)
    except all_errors as e:
        # @ToDo Save the error in the database
        sys.exit("Cannot upload file")
if __name__ == '__main__':
    # Login info
    host = 'ftp-private.ncbi.nlm.nih.gov'
    user = 'CDC-SC2CLIA'
    password = input("Enter password:")
    # Submission directory info
    type = "Test"  # Production
    now = datetime.datetime.now()
    subdir = "{}_{}".format(user, now.strftime("%Y.%m.%d-%H.%M.%S"))
    # Files for upload (assume in upload directory)
    xml_file = "submission.xml"
    zip_file = "submission.zip"
    submit_file = "submit.ready"
    with FTP(host) as genbank_ftp:
        login(genbank_ftp, user, password)
        change_dir(genbank_ftp, type)
        make_subdir(genbank_ftp, subdir)
        change_dir(genbank_ftp, subdir)
        upload_file(genbank_ftp, xml_file)
        upload_file(genbank_ftp, zip_file)
        upload_file(genbank_ftp, submit_file)
    # logger.info("Files have been uploaded to ", subdir)
    # sys.exit()
