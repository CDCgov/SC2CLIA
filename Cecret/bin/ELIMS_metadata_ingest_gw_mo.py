import json
import requests
import sys
import re
import argparse 

# Suppress internal https warnings
import urllib3
urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)

#### ENDPOINT CONFIG ########
elims_id = 'DVD1'
elims_key = 'dvd123'
elims_server_root = 'https://elimswshub-dev.cdc.gov/ELIMSWSHUB_DEV'

elims_id = 'DVD1'
elims_key = 'Prod-Fj8x8Q9j!z'
elims_server_root = 'https://elimswshub.cdc.gov/ELIMSWSHUB/'

#############################
# ELIMS API Field Definitions

"""
df = pd.DataFrame(columns=['CSID', 'CUID', 'SPHLSpecimenID', 'Origin', 'SpecimenCollectedDate', 'SpecimenSourceType', 
							'Purpose', 'TestOrderName', 'CDCEventID', 'Age', 'AgeUnits', 'Sex', 'Race', 
							'PrevLabResults', 'Comments', 'geo_location', 'USResidenceState', 
							'DateofOnset', 'Fatal', 'SOISymptomatic', 'SOIAsymptomatic', 'SOIAcute', 
							'ClinicalSummary', 'TreatmentInfo', 'Immunization1', 'Immunization1Date', 
							'Travel', 'TravelForeign1', 'TravelUS1', 'TravelCounty', 'TravelCity', 'TravelStartDate', 'TravelEndDate', 
							'SPHLID', 'SPHLState', 'SPHLName', 'SPHLPatientID', 'SPHLPOCLName', 'SPHLPOCFName', 
							'OrigSubID', 'OrigSubName', 'OriginalSubCountry', 'OriginalSubCity', 'OrigSubState', 'OrigSubZip', 
							'Numeric01', 'Numeric02', 'ProcessedFlag', 'AdditionalID1', 'AdditionalType1', 'AdditionalID2', 'AdditionalType2'])
"""

valSubs = {'Alabama':'USA: AL', 		'Alaska':'USA: AK', 		'Arizona':'USA: AZ', 		'Arkansas':'USA: AR', 		'California':'USA: CA', 
			'Colorado':'USA: CO', 		'Connecticut':'USA: CT', 	'Delaware':'USA: DE', 		'Florida':'USA: FL', 		'Georgia':'USA: GA', 
			'Hawaii':'USA: HI', 		'Idaho':'USA: ID', 			'Illinois':'USA: IL', 		'Indiana':'USA: IN', 		'Iowa':'USA: IA', 
			'Kansas':'USA: KS', 		'Kentucky':'USA: KY', 		'Louisiana':'USA: LA', 		'Maine':'USA: ME', 			'Maryland':'USA: MD', 
			'Massachusetts':'USA: MA',	'Michigan':'USA: MI', 		'Minnesota':'USA: MN', 		'Mississippi':'USA: MS', 	'Missouri':'USA: MO',
			'Montana':'USA: MT', 		'Nebraska':'USA: NE',		'Nevada':'USA: NV',			'New Hampshire':'USA: NH',	'New Jersey':'USA: NJ',
			'New Mexico':'USA: NM', 	'New York':'USA: NY',		'North Carolina':'USA: NC',	'North Dakota':'USA: ND',	'Ohio':'USA: OH',
			'Oklahoma':'USA: OK', 		'Oregon':'USA: OR',			'Pennsylvania':'USA: PA',	'Rhode Island':'USA: RI',	'South Carolina':'USA: SC',
			'South Dakota':'USA: SD', 	'Tennessee':'USA: TN',		'Texas':'USA: TX',			'Utah':'USA: UT',			'Vermont':'USA: VT',
			'Virginia':'USA: VA',		'Washington':'USA: WA', 	'West Virginia':'USA: WV',	'Wisconsin':'USA: WI',		'Wyoming':'USA: WY'}

fldMask = {'CSID':'CSID', 'CUID':'CUID', 'Origin':'host', 'SPHLState':'country', 'SpecimenCollectedDate':'collection-date', 
			'SpecimenSourceType':'isolation-source'}

def getCUID(args):
	"""
	Arguments (from global args):  comma-separated list of CUIDs (or CSIDs)
	
	Returns:  list of input values if formatted as expected (8-character CUID or 10-number CSID)
	"""
	cuid_list = []
	for i in args.idinput.split(','):
		if re.match('[0-9A-Z]{8}$', i):
			# input formatted as CUID
			cuid_list.append(i)
		elif re.match('[0-9]{10}', i):
			# input formatted as CSID
			cuid_list.append(i)
		else:
			print('Bad ID: {}\n'.format(i), file=sys.stderr)
	if len(cuid_list) == 0:
		sys.exit('No valid CUIDs input')

	return(cuid_list)


def usage(ec=0):
	msg='''
	Usage example:
		{} ZZYHFU8A,ZZYHFU8B,ZZYHFU8C,ZZYHFU8D,ZZYHFU8E
	'''.format(sys.argv[0])
	msg=re.sub(r'^\s', '', msg, flags=re.M)
	print(msg)
	exit(ec)

		
def ELIMS2json(cuid_list, sidtype='CUID'):
	"""
	Arguments:  cuid_list -> list of ID's (CUID or CSID) to pull
				sidtype -> string denoting which ID type cuid_list contains
	Returns:	string --> all corresponding field:value pairs from cuid_list sent to ELIMS
	"""
	url = '/'.join([elims_server_root, 'Default/Get_Sample_Metadata'])
	body = '{{ "System_ID": "{id}", "Key":"{key}", "SampleIDType": "{sidtype}", "SampleIDs": "{cuid_list}" }}'.format(id=elims_id, key=elims_key, sidtype=sidtype, cuid_list=','.join(cuid_list))
	headers = {'Content-Type': 'application/json'}
	# send request to ELIMS web services 
	req = requests.post(url, headers=headers, data=body, verify=False)
	# return results converted from string to list of dictionaries
	return(json.loads(req.text)['Data'])

def NCBI_data_conversion(data, id_list, idtype):
	# Change values for NCBI based on Origin field being Human or not
	for d in data:
		if d['Origin']=='Human':
			d['Origin'] = 'Homo sapien'
			d['SpecimenSourceType'] = 'clinical'
		else:
			d['Origin'] = 'missing'
			d['SpecimenSourceType'] = 'non-clinical'
	
	# Compile results for NCBI
	elimsVals = {id:{'Organism':'Severe acute respiratory syndrome coronavirus 2'} for id in id_list}
	for d in data:
		for id in id_list:
			if idtype=="CUID":
				if d['CUID']==id:
					elimsVals[id].update({fldMask[key]:valSubs.get(val, val) for key, val in d.items() if key in set(fldMask.keys()) ^ set(['CSID', 'CUID'])})
			else:
				if d['CSID']==id:
					elimsVals[id].update({fldMask[key]:valSubs.get(val, val) for key, val in d.items() if key in set(fldMask.keys()) ^ set(['CSID', 'CUID'])})
	# print(elimsVals)
	return (elimsVals)

# this function will take a list of csid(str, NOT int)
# and return a dictionary for NCBI uploading
def get_dict_NCBI_UPLOAD(list_csid):

	idtype = 'CSID' # assume we take a list of csid
	
	# Get data from ELIMS for provided IDs
	data = ELIMS2json(list_csid, idtype)

	return (NCBI_data_conversion(data, list_csid, idtype))




def main():

	if len(sys.argv) == 1:
		usage(1)
	# Add arguments for potential use
	parser = argparse.ArgumentParser()
	parser.add_argument("idinput", 
				help="Comma-separated list of CUIDs/CSIDs")
	parser.add_argument("--outfile",
				nargs = 1,
				help="Dump output to the file specified instead of loading directly to Hadoop")
	parser.add_argument("--outpath",
				nargs = 1,
				help="Dump output this location, autonaming file.")
	parser.add_argument("--csid", 
				action='store_true',
				help="Input is CSID.")
	
	# Get provided arguments from input
	args=parser.parse_args()
	
	# Denote type of IDs (CUID or CSID) from input (default:  CUID)
	if args.csid:
		idtype = 'CSID'
	else:
		idtype = 'CUID'
	
	# Get list of IDs from input args
	id_list = getCUID(args)
	
	# Get data from ELIMS for provided IDs
	data = ELIMS2json(id_list, idtype)

	print(NCBI_data_conversion(data, id_list, idtype))
	


if __name__ == '__main__':

	main()
