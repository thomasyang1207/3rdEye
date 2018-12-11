def genRecord(file):
	#reads the line
	records = []
	with open(file, 'r') as fd:
		for line in fd:
			procString = ''.join([c for c in line if c != '}' and c != '{' and c != '\t' and c != ' ']).split(',')[:2]
			if len(procString) <= 1: continue
			records.append(procString)

	prefix = '\"0110000\", \'0\', \'0\', '
	with open('Records', 'w') as fd:
		for rec in records:
			reg = 'x\"' + rec[0][2:] + '\"'
			dat = 'x\"' + rec[1][2:] + '\"'
			fd.write('\t\t('+prefix + reg + ', ' + dat + '), \n')



if __name__ == '__main__':
	genRecord('Registers.c')