extends Node

# ==== Transition Signals ==== #
signal Place_Bet # 1 var, Betted Amount

# ==== Round Signals ==== #
signal Player_Sum # 1 var, Card Sum
signal New_Jackpot # 1 var, Jackpot Num
signal End_Round # 1 var, Rounds pass usally 1
signal Returned_Amount # 1 var, Returned Amount
signal New_MinBetting # no var

# ==== Card Transformation Signals ==== #
signal Card_Transform # 1 var, 1-13 to choose card
signal Card_Chosen # No var
signal Card_Replacer # 1 var, 1-13 to choose card
signal Reset_CardChosen # No var
signal Card_YesChange # No var
signal Card_NoChange # No var
signal Update_ActionArray # 2 var, New Number - Old Number

# ==== Oppenent Signals ==== #
signal Oppenent_RollCards # No var
signal Oppenent_ClearCards # No var
signal Oppenents_CardReport # 2 var, Enemy Num - Card Sum
signal Oppenent_ReportCards # No var


# ==== Cheating Signals ==== #
signal In_CheatingMode # No var, Called Twice for one funtion to work however
signal Cheater_Check # No var, Called Twice for one funtion to work however
signal Cheater_Catch # No var
signal Change_Sus # 1 var, Added Amount
signal Lose_Sus # 1 var, Subtracted Amount
signal End_Game # No varibles

# ==== Dealer Signals ==== #
signal Request_Card # No var
signal Give_Card # One var, Node Card
signal Change_Card
