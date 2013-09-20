with open("blink.hex") as f:
	content = f.readlines()

for raw in content:
	line = raw.strip()
	byte_count = int(line[1:3], 16)
	address = line[3:7]
	record_type = int(line[7:9], 16)
	data = line[9:9 + 2*byte_count]
	#checksum = 

	if(record_type == 0):
		print "DATA", "@"+address, "= " + ", ".join([str(int(data[i:i+2], 16)) for i in range(0, len(data), 2)])
	elif(record_type == 1):
		print "EOF", "@"+address, "="+data
	elif(record_type == 2):
		address = line[7:15]
		print "EXT SEG", "@"+address
	elif(record_type == 3):
		print "START SEG", "@"+address, "="+data
	elif(record_type == 4):
		print "EXT LIN", "@"+address, "="+data
	elif(record_type == 5):
		print "START LIN", "@"+address, "="+data
	else:
		print "UNRECOGNIZED", "@"+address, "="+data
