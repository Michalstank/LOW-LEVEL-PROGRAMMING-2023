.global _start
_start:
	//"Main" Function of the Program

	ldr r1, =input				//Load input String to r1
	
	bl checkInput				//Branch to Check Input, Uses r8, r2 & r1
	
	cmp r8, #0x01				//Compare String Count with Minimal Length
	movle r9, #0x00				//Load Fail to r9 if Input Length <= 1
	ble outputCTRL				//Branch to Output Control If Input Length <= 1
	
	mov r8, #0x00				//Reset r8
	
	ldr r4, =input				//Load Input String to r4
								//Input Strings Located In r1 & r4
	
								//Since checkInput Branch Moved r1 "Cursor" to the end of Input String
	sub r1, r1, #1				//Move r1 back to a readable char and NOT NULL/0x00
	bl palinFinder				//Branch To PalinFinder
	
	b outputCTRL				//Branch to Output Control			
								
	b end	 					//Exit Program, Failsafe

checkInput:

	ldrb r2, [r1]				//Load Input String Character to r2 from r1
	
	cmp r2, #0x00				//Check If It Is a Character
	
	addne r1, r1 ,#0x01			//If NOT == NULL, move memory "Cursor" by 1 Byte
	addne r8, r8, #0x01			//Consider r8 a Length Counter, add 1 on Character Detected
	
	bne checkInput				//Internal loop untill done iterating over r1
	
	bx lr						//Return From Branch

palinFinder:
								//Both r1 and r4 Have Input String
								//r1 is at the end while r4 is at the start
	ldrb r2, [r1]
	ldrb r3, [r4]				//Load Chracters From The String to r2 and r3
	
	cmp r3, #0x00				//Check if End Of String 
	
	moveq r9, #0x01				//If End Of String And No Issues Set r9 To Palindrome Found
	beq exit					//Exit PalinFinder
	
	cmp r2, #0x20				//Check If r2 = Whitespace
	
	subeq r1,r1,#0x01			//Move r1 "Cursor" by one (-1)
	beq palinFinder				//Return To Start Of Loop
	
	cmp r3, #0x20				//Check If r3 = Whitespace
	
	addeq r4,r4,#0x01			//Move r4 "Cursor" by one (+1)
	beq palinFinder				//Return To Start Of Loop
	
	push {lr}					//Save Branch Link On The Stack
	bl toLowercase				//Branch To toLowercase
	pop {lr}					//Restore Branch Link From The Stack
	
	cmp r2, r3					//Compare r2, r3
	
	movne r9, #0x00				//If Not Equal Change r9 to Palindrome Not Found
	bne	exit					//If Not Equal Exit Branch
	
	subeq r1, r1, #0x01			//Move r1 "Cursor" by 1 (-1)
	addeq r4, r4, #0x01			//Move r4 "Cursor" by 1 (+1)
				
	beq palinFinder

	bx lr
	
exit:							//Function Can be called using cmp
	bx lr						//Condictional bx lr
	
toLowercase:
								//r2 Processing To Lowercase
	cmp r2, #0x40 				//If Higher Than First Uppercase on ASCII Table

	movgt r6, #0x01				//Within Range of Uppercase Letters
	movle r6, #0x00				//Not Within Range

	cmp r2, #0x5B				//Compare If Lower than last Uppercase on ASCII Table
	
	movlt r7, #0x01				//Within Range of Uppercase Letters
	movge r7, #0x00				//Not Within Range
	
	and r6, r6, r7				//Bitwise AND, r6 & r7, Store Result In r6
	
	cmp r6, #0x01				//Compare r6 With Defined Value For Within Range Of Uppercase
	
	addeq r2, #0x20				//Add 0x20 to r2 If It Was Uppercase Setting It As Lowercase In ASCII Table
	
								//r3 Processing To Lowercase - Repeat of r2 Processing
	cmp r3, #0x40 				//If Higher Than First Uppercase on ASCII Table

	movgt r6, #0x01				//Within Range of Uppercase Letters
	movle r6, #0x00				//Not Within Range

	cmp r3, #0x5B				//Compare If Lower than last Uppercase on ASCII Table
	
	movlt r7, #0x01				//Within Range of Uppercase Letters
	movge r7, #0x00				//Not Within Range
	
	and r6, r6, r7				//Bitwise AND, r6 & r7, Store Result In r6
	
	cmp r6, #0x01				//Compare r6 With Defined Value For Within Range Of Uppercase
	
	addeq r3, #0x20				//Add 0x20 to r3 If It Was Uppercase Setting It As Lowercase In ASCII Table

	bx lr						//Branch Back To "Main"
	
outputCTRL: 
	cmp r9, #0x01				//Check if Palindrome
	
	ldr r0, =0xff200000			//Set r0 to point to LEDs Register
	
	bleq ledPOS					//Branch to	positive LEDs Output Branch
	blne ledNEG					//Branch to negative LEDs Output Branch
	
	ldr r0, =0xff201000			//Set r0 to point to UART Register
	
	bl UART_PRINT				//Branch to UART_PRINT
	
	b end						//Branch to end
UART_PRINT:
	ldrb r2, [r1]				//Load Character to r2 from r1
	
	cmp r2, #0x00				//Compare If End Of String
	
	strne r2, [r0]				//If NOT End Of String, Print Character To UART
	
	addne r1, r1 ,#1			//If NOT End Of String, move r1 "Cursor" by 1 Byte (+1)
	
	bne UART_PRINT				//Internal Loop Untill End Of String
	
	bx lr						//Return From Branch
ledPOS:
	push {r8}					//Store r8 on stack
	mov r8, #0b0000011111		//Load Values For LEDs To r8
	str r8, [r0]				//Set LEDs
	pop {r8}					//Restore r8 Value From Stack
	
	ldr r1, =pos_output			//Load Output String For PalindromeFound to r1
	
	bx lr						//Return From Branch
ledNEG:
	push {r8}					//Store r8 on stack
	mov r8, #0b1111100000		//Load Values For LEDs To r8
	str r8, [r0]				//Set LEDs
	pop {r8}					//Restore r8 Value From Stack
	
	ldr r1, =neg_output			//Load Output String For PalindromeNotFound to r1
	
	bx lr						//Return From Branch
end: 
	b end						//Infinite Loop, End Of Program
	
.data
.align
	// This is the input you are supposed to check for a palindrom
	// You can modify the string during development, however you
	// are not allowed to change the name 'input'!
	input: .asciz "Grav ned den varg"
	pos_output: .asciz "Palindrome Detected."
	neg_output: .asciz "Not a Palindrome."

