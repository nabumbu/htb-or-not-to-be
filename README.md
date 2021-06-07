# htb-or-not-to-be

A Bash Script that interacts with HackTheBox throught its API v4
## ...STILL TESTING...
List active machines
```bash
./htb-or-not-to-be -l active
```

List retired machines
```bash
./htb-or-not-to-be -l retired
```
List machine and sort (<key>--> (level|id|name|...) )
```bash
./htb-or-not-to-be -l <active|retired> -k <key>
```

Play machine
```bash
./htb-or-not-to-be -p <MACHINE-NAME>
```

Stop opened machine
```bash
./htb-or-not-to-be -s
```
