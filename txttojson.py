fin = open("words.txt", "r")
fout = open("words.json", "a+")
words = fin.read()
words = words.split("\n")
fin.close()
rnd = 0
fout.write('[\n')
for w in words:
    fout.write('\t"' + w + '",\n')
    print(w)
    rnd += 1
fout.write(']')
fout.close()
