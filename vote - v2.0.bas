/* Poll Smart Contract in DVM-BASIC  
   Version 2.0
   MIT License
   Created by Cryptolemico :)
*/

Function Initialize() Uint64
  10  STORE("owner_addr",SIGNER())
  11  PRINTF "Initialize Smart Contarct Data"
  12  RETURN 0 
End Function 


/* EXECUTABLE SC FUNCTIONS*/


Function TransferOwnership(newowner String) Uint64 
  10  IF ADDRESS_RAW(LOAD("owner_addr")) == ADDRESS_RAW(SIGNER()) THEN GOTO 20 
  11  RETURN 1

  20  STORE("tmpowner_addr",newowner)
  21  RETURN 0
End Function
  
  
Function ClaimOwnership() Uint64 
  10  IF ADDRESS_RAW(LOAD("tmpowner_addr")) == ADDRESS_RAW(SIGNER()) THEN GOTO 20 
  11  RETURN 1

  20  STORE("owner_addr",SIGNER())
  21  RETURN 0
End Function


Function New_Poll(name String) Uint64  
  10  IF EXISTS(name + "_name") == 0 THEN GOTO 20
  11  PRINTF "Poll name already exist!"
  12  RETURN 1  

  20  IF ADDRESS_RAW(LOAD("owner_addr")) == ADDRESS_RAW(SIGNER()) THEN GOTO 30
  21  PRINTF "You are not allowed to create new poll!"
  22  RETURN 1

  30  STORE(name + "_name", name)
  31  STORE(name + "_voter_counter",0)
  32  STORE(name + "_vote_yes",0)
  33  STORE(name + "_vote_no",0)
  34  STORE(name + "_close_poll",0)`
  35  STORE(name + "_block_height",BLOCK_HEIGHT())
  36  STORE(name + "_block_topoheight",BLOCK_TOPOHEIGHT())
  37  STORE(name + "_closed",0)
  38  STORE(name + "_force_closing",0)
  39  STORE(name + "_close_at_block",0) //if 0 no time limit  
  40  PRINTF "New poll %s created!" name
  41  RETURN 0
End Function 


Function Set_Poll_BlockHeight (name String, blockHeight Uint64) Uint64  
  10  IF EXISTS(name + "_name") == 0 THEN GOTO 20
  11  PRINTF "Poll name already exist!"
  12  RETURN 1  

  20  IF ADDRESS_RAW(LOAD("owner_addr")) == ADDRESS_RAW(SIGNER()) THEN GOTO 30
  21  PRINTF "You are not allowed to change blockHeight!"
  22  RETURN 1

  30  IF Close_Poll(name) > 0 THEN GOTO 40
  31  RETURN 1   

  40  STORE(name + "_close_at_block",blockHeight) //if 0 no time limit
  41  PRINTF "New blockHeight set: %d!" blockHeight  
  42  RETURN 0
End Function 


Function Close_Poll(name String) Uint64 
  10  IF EXISTS(name + "_name") == 1 THEN GOTO 20
  11  PRINTF "This poll doesn't exist!"
  12  RETURN 1

  20  IF ADDRESS_RAW(LOAD("owner_addr")) == ADDRESS_RAW(SIGNER()) THEN GOTO 30
  21  PRINTF "You are not the owner of this poll!"
  22  RETURN 1

  30  IF LOAD(name + "_closed") == 0 THEN GOTO 40
  31  PRINTF "This poll is already closed!"
  32  RETURN 0

  40  IF LOAD(name + "_force_closing") == 0 THEN GOTO 50
  41  STORE(name + "_close_at_block",BLOCK_HEIGHT())
  42  STORE(name + "_closed",1)
  43  PRINTF "Force closing poll... "
  44  RETURN 0

  50  IF LOAD(name + "_close_at_block") > 0 THEN GOTO 60
  51  PRINTF "Poll ongoing. No blockHeight set!"
  52  RETURN 1
  
  60  DIM _close_at_block as Uint64
  61  LET _close_at_block = LOAD(name + "_close_at_block")
  62  IF _close_at_block >= BLOCK_HEIGHT() THEN GOTO 70
  63  STORE(name + "_close_at_block", BLOCK_HEIGHT())
  64  STORE(name + "_closed", 1)
  65  PRINTF "Poll closed!"
  66  RETURN 0

  70  PRINTF "Poll ongoing! No blockHeight reached!"
  71  RETURN 1
End Function 


Function Force_Closing_Poll (name String) Uint64
  10  IF EXISTS(name + "_name") == 1 THEN GOTO 20
  11  PRINTF "This poll doesn't exist!"
  12  RETURN 1

  20  IF ADDRESS_RAW(LOAD("owner_addr")) == ADDRESS_RAW(SIGNER()) THEN GOTO 30
  21  PRINTF "You are not allowed to rename the poll!"
  21  RETURN 1  

  30  STORE(name + "_force_closing",1)
  31  Close_Poll(name)
  32  PRINTF "Poll closed!"
  33  RETURN 0
End Function 


Function Rename_Poll(name String) Uint64
  10  IF EXISTS(name + "name") == 1 THEN GOTO 20
  11  PRINTF "This poll doesn't exist!"
  12  RETURN 1

  20  IF ADDRESS_RAW(LOAD("owner_addr")) == ADDRESS_RAW(SIGNER()) THEN GOTO 30
  21  PRINTF "You are not allowed to rename the poll!"
  21  RETURN 1  
  
  30  IF Close_Poll(name) > 0 THEN GOTO 40
  31  RETURN 1   

  40  STORE(name + tmp_poll_number, name)  
  41  PRINTF "Poll renamed: %s" name  
  42  RETURN 0
End Function 


Function Show_Results(name String) Uint64
  10  IF EXISTS(name + "name") == 1 THEN GOTO 20
  11  PRINTF "This poll doesn't exist!"
  12  RETURN 1

  20  IF LOAD(name + "_closed") == 0 THEN GOTO 30
  21  PRINTF "This poll is closed /!\"
  22  PRINTF "Poll closed at block %d" LOAD(name + "_close_at_block")

  30  PRINTF "Name of pool: %s" LOAD(name + "_name")
  31  PRINTF "Total of voters: %d" LOAD(name + "_voter_counter")
  32  PRINTF "Number of people voted Yes: %d" LOAD(name + "_vote_yes")
  33  PRINTF "Number of people voted No: %d" LOAD(name + "_vote_no")
  34  RETURN 0
End Function 


Function Add_Voter(name String, voter String) Uint64 
  10  IF EXISTS(name + "name") == 1 THEN GOTO 20
  11  PRINTF "This poll doesn't exist!"
  12  RETURN 1

  20  IF IS_ADDRESS_VALID(voter) == 1 THEN GOTO 30
  21  PRINTF "Invalid voter address!"
  22  RETURN 1  

  30  IF ADDRESS_RAW(LOAD("owner_addr")) == ADDRESS_RAW(SIGNER()) THEN GOTO 50 
  31  PRINTF "You have not privilege to add voter!"
  32  RETURN 1  

  40  IF Close_Poll(name) > 0 THEN GOTO 40
  41  RETURN 1     

  50  DIM _iterator as Uint64
  51  LET _iterator = LOAD(name + "_voter_counter")
  52  IF _iterator == 0 THEN GOTO 60 // stack empty than no duplicated address
  53  LET _iterator = _iterator - 1  
  54  IF ADDRESS_RAW(LOAD(name + "_voter" + _iterator)) != ADDRESS_RAW(voter) THEN GOTO 57
  55  PRINTF "Voter alredy added!"
  56  RETURN 1
  57  IF _iterator > 0 THEN GOTO 53

  60  DIM _voter_counter as Uint64
  61  LET _voter_counter = LOAD(name + "_voter_counter")
  62  STORE(name + "_voter" + _voter_counter,voter)
  63  STORE(name + "_has_voted" + _voter_counter,0)
  64  STORE(name + "_voter_counter",_voter_counter + 1)
  65  PRINTF "Voter added!"
  66  RETURN 0
End Function


Function Remove_Voter(name String, voter String) Uint64 
  10  IF EXISTS(name + "_name") == 1 THEN GOTO 20
  11  PRINTF "This poll doesn't exist!"
  12  RETURN 1
  
  20  IF IS_ADDRESS_VALID(voter) == 1 THEN GOTO 30
  21  PRINTF "Invalid voter address!"
  22  RETURN 1  
  
  30  IF ADDRESS_RAW(LOAD("owner_addr")) == ADDRESS_RAW(SIGNER()) THEN GOTO 50 
  31  PRINTF "You have not privilege to remove voter!"
  32  RETURN 1
  
  40  IF Close_Poll(name) > 0 THEN GOTO 40
  41  RETURN 1 
  
  50  DIM _voter_counter as Uint64
  51  LET _voter_counter = LOAD(name + "_voter_counter")  
  52  IF _voter_counter > 0 THEN GOTO 60
  53  PRINTF "No voter to remove!"
  54  RETURN 1
  
  60  LET _voter_counter = _voter_counter - 1  
  61  IF ADDRESS_RAW(LOAD(name + "_voter" + _voter_counter)) != ADDRESS_RAW(voter) THEN GOTO 65
  62  STORE(name + "_voter" + _voter_counter, "NULL")
  63  PRINTF "Voter removed!"
  64  RETURN 0
  65  IF _voter_counter > 0 THEN GOTO 60
  
  70  PRINTF "Voter NOT found!"
  71  RETURN 1
End Function


Function Vote_Yes(name String) Uint64
  10  IF EXISTS(name + "_name") == 1 THEN GOTO 20
  11  PRINTF "This poll doesn't exist!"
  12  RETURN 1
  
  20  IF Close_Poll(name) > 0 THEN GOTO 30
  21  RETURN 1

  30  DIM _voter_counter as Uint64
  31  LET _voter_counter = LOAD(name + "_voter_counter")
  32  IF _voter_counter > 0 THEN GOTO 40
  33  PRINTF "No voters added to the poll!"
  34  RETURN 1

  40  IF ADDRESS_RAW(LOAD(name + "_voter" + _voter_counter)) != ADDRESS_RAW(SIGNER()) THEN GOTO 48
  41  IF LOAD(name + "has_voted" + _voter_counter) > 0 THEN GOTO 46
  42  STORE(name + "_vote_yes", LOAD(name + "vote_yes")+1)
  43  STORE(name + "_has_voted" + _voter_counter, 1)
  44  PRINTF "Thanks for voting!"
  45  RETURN 0
  46  PRINTF "You have already voted!"
  47  RETURN 1
  48  IF _voter_counter > 0 THEN GOTO 40
  
  50  PRINTF "You are not allowed to vote!"
  51  RETURN 1
End Function 


Function Vote_No(name String) Uint64
  10  IF EXISTS(name + "_name") == 1 THEN GOTO 20
  11  PRINTF "This poll doesn't exist!"
  12  RETURN 1
  
  20  IF Close_Poll(name) > 0 THEN GOTO 30
  21  RETURN 1   

  30  DIM _voter_counter as Uint64
  31  LET _voter_counter = LOAD(name + "_voter_counter")
  32  IF _voter_counter > 0 THEN GOTO 40
  33  PRINTF "No voters added to the poll!"
  34  RETURN 1

  40  IF ADDRESS_RAW(LOAD(name + "_voter" + _voter_counter)) != ADDRESS_RAW(SIGNER()) THEN GOTO 48
  41  IF LOAD(name + "has_voted" + _voter_counter) > 0 THEN GOTO 46
  42  STORE(name + "_vote_no", LOAD(name + "vote_no")+1)
  43  STORE(name + "_has_voted" + _voter_counter, 1)
  44  PRINTF "Thanks for voting!"
  45  RETURN 0
  46  PRINTF "You have already voted!"
  47  RETURN 1
  48  IF _voter_counter > 0 THEN GOTO 40
  
  40  PRINTF "You are not allowed to vote!"
  41  RETURN 1
End Function 