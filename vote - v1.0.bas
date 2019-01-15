/* Vote Smart Contract in DVM-BASIC  
   This smart contract is used to vote saftely without cheating.
*/


// this function is used to initialize parameters during install time
Function Initialize() Uint64
	/* license and version*/
	1	STORE("version","1.0")
	2	STORE("license","MIT license")
	/* set parameters */
	10	STORE("vote_name","Test Poll")	'<-- Change the poll name
	11  STORE("owner_addr",SIGNER())
	12  STORE("owner_name","owner")	'<-- Change the owner name	
	13  STORE("vote_count",0)
	14	STORE("vote_yes",0)
	15	STORE("vote_no",0)
	16	STORE("vote_array_prefix",0)
	20  PRINTF "Initialize Smart Contarct Data"
	30  RETURN 0 
End Function 


Function Show_Results() Uint64
	10	PRINTF "Name of pool: %s" LOAD("vote_name")
	11  PRINTF "Number of people voted Yes: %d" LOAD("vote_yes")
	12	PRINTF "Number of people voted No: %d" LOAD("vote_no")
	20  RETURN 0
End Function 


Function Vote_Yes() Uint64
	10	dim vote_count_tmp as Uint64
	20	LET vote_count_tmp = LOAD("vote_count")
	30	IF vote_count_tmp > 0 THEN GOTO 40	// check if exist some voter addresses
		31 PRINTF "Stack is empty than nobody can vote!"
		32 RETURN 1
	40	LET vote_count_tmp = vote_count_tmp - 1	
	50	IF ADDRESS_RAW(LOAD("voter" + vote_count_tmp)) != ADDRESS_RAW(SIGNER()) THEN GOTO 60
		51 IF LOAD("has_voted" + vote_count_tmp) != 0 THEN GOTO 56
			52 STORE("vote_yes", LOAD("vote_yes")+1)
			53 STORE("has_voted" + vote_count_tmp, 1)
			54 PRINTF "Thanks for voting!"
			55 RETURN 0
		56 PRINTF "You have already voted!"
		57 RETURN 1
	60	IF vote_count_tmp > 0 THEN GOTO 40
	70  PRINTF "You are not allowed to vote!"
	80  RETURN 1
End Function 


Function Vote_No() Uint64
	10	dim vote_count_tmp as Uint64
	20	LET vote_count_tmp = LOAD("vote_count")
	30	IF vote_count_tmp > 0 THEN GOTO 40	// check if exist some voter addresses
		31 PRINTF "Stack is empty than nobody can vote!"
		32 RETURN 1
	40	LET vote_count_tmp = vote_count_tmp - 1	
	50	IF ADDRESS_RAW(LOAD("voter" + vote_count_tmp)) != ADDRESS_RAW(SIGNER()) THEN GOTO 60
		51 IF LOAD("has_voted" + vote_count_tmp) != 0 THEN GOTO 56
			52 STORE("vote_no", LOAD("vote_no")+1)
			53 STORE("has_voted" + vote_count_tmp, 1)
			54 PRINTF "Thanks for voting!"
			55 RETURN 0
		56 PRINTF "You have already voted!"
		57 RETURN 1
	60	IF vote_count_tmp > 0 THEN GOTO 40
	70  PRINTF "You are not allowed to vote!"
	80  RETURN 1
End Function 


Function Add_Voter(voter String) Uint64 
	10	dim vote_count_tmp as Uint64
	20	LET vote_count_tmp = LOAD("vote_count")
	30	IF IS_ADDRESS_VALID(voter) == 1 THEN GOTO 40
        31 PRINTF "Invalid voter address!"
        32 RETURN 1	
	40  IF ADDRESS_RAW(LOAD("owner_addr")) == ADDRESS_RAW(SIGNER()) THEN GOTO 50 
		41 PRINTF "You have not privilege to add voter!"
		42 RETURN 1			
	50	IF vote_count_tmp == 0 THEN GOTO 90 // stack empty than no duplicated address
	60	LET vote_count_tmp = vote_count_tmp - 1	
	70	IF ADDRESS_RAW(LOAD("voter" + vote_count_tmp)) != ADDRESS_RAW(voter) THEN GOTO 80
		71 PRINTF "Voter already added!"
		72 RETURN 1
	80	IF vote_count_tmp > 0 THEN GOTO 60
	90	STORE("voter" + LOAD("vote_count"),voter)
	100 STORE("has_voted" + LOAD("vote_count"),0)
	110	STORE("vote_count",LOAD("vote_count") + 1)
	120	PRINTF "Voter added!"
	130 RETURN 0
End Function


Function Remove_Voter(voter String) Uint64 
	10	dim vote_count_tmp as Uint64
	20	LET vote_count_tmp = LOAD("vote_count")	
	30	IF IS_ADDRESS_VALID(voter) == 1 THEN GOTO 40
        31 PRINTF "Invalid voter address!"
        32 RETURN 1		
	40  IF ADDRESS_RAW(LOAD("owner_addr")) == ADDRESS_RAW(SIGNER()) THEN GOTO 50
		41 PRINTF "You have not privilege to remove voter!"
		42 RETURN 1	
	50	IF vote_count_tmp > 0 THEN GOTO 60
		51 PRINTF "Empty voter stack!"
		52 RETURN 1	
	60	LET vote_count_tmp = vote_count_tmp - 1	
	70	IF ADDRESS_RAW(LOAD("voter" + vote_count_tmp)) != ADDRESS_RAW(voter) THEN GOTO 80
		71 STORE("voter" + vote_count_tmp) = "NULL"
		72 PRINTF "Voter removed!"
		73 RETURN 0
	80	IF vote_count_tmp > 0 THEN GOTO 60
	90	PRINTF "Voter NOT found!"
	100 RETURN 1
End Function