cmdstr = (
"set_property INIT_{} {} [get_cells video_pipeline_inst/fb0"
"/ramb64x1_inst_{}/RAMB36E1_lower]"
)

init_vectors = []
# Generate vectors
for i in range(0, 256):
	init_vectors.append("{:02X}".format(i))

test_string = """
This is a test string. One, two, three, four, five, six, seven, eight,
nine, ten. Yes, this is quite functional. The following will test the
special characters: ¬!"£$%^&*()_+}{~@?><:,./;'#][=-0987654321`\|"""

memory_rep = []

# Generate memory rep
for i in test_string:
	memory_rep.append("{:08b}".format(ord(i)));

# Generate individual vectors
v0 = []
v1 = []
v2 = []
v3 = []
v4 = []
v5 = []
v6 = []
v7 = []

for i in reversed(memory_rep):
	v7.append(i[0])
	v6.append(i[1])
	v5.append(i[2])
	v4.append(i[3])
	v3.append(i[4])
	v2.append(i[5])
	v1.append(i[6])
	v0.append(i[7])

ramb0 = hex(int("".join(v0), 2))
ramb1 = hex(int("".join(v1), 2))
ramb2 = hex(int("".join(v2), 2))
ramb3 = hex(int("".join(v3), 2))
ramb4 = hex(int("".join(v4), 2))
ramb5 = hex(int("".join(v5), 2))
ramb6 = hex(int("".join(v6), 2))
ramb7 = hex(int("".join(v7), 2))

#print("v7 = " + ramb7)
#print("v6 = " + ramb6)
#print("v5 = " + ramb5)
#print("v4 = " + ramb4)
#print("v3 = " + ramb3)
#print("v2 = " + ramb2)
#print("v1 = " + ramb1)
#print("v0 = " + ramb0)

cmdfile = ""
j = 0
for i in [ramb0, ramb1, ramb2, ramb3, ramb4, ramb5, ramb6, ramb7]:
	cmdfile += cmdstr.format("00", i, j) + "\n"
	j += 1

print(cmdfile)
