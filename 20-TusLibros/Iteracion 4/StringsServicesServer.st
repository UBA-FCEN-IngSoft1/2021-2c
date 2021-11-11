!classDefinition: #StringGenius category: 'StringsServicesServer'!
Object subclass: #StringGenius
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'StringsServicesServer'!

!StringGenius methodsFor: 'converting' stamp: 'NR 11/11/2019 16:14:06'!
firstLetter: aWord
	
	^aWord at:1! !

!StringGenius methodsFor: 'converting' stamp: 'NR 6/24/2021 19:12:44'!
removeSpecialCharacters: aSentence
	
	^aSentence select:[:ch| ch isAlphaNumeric or: [ch isSeparator ]].! !

!StringGenius methodsFor: 'converting' stamp: 'NR 11/11/2019 16:14:58'!
toLowercase: aWord
	
	^aWord translateToLowercase! !

!StringGenius methodsFor: 'converting' stamp: 'NR 11/11/2019 16:14:47'!
toUppercase: aWord
	
	^aWord translateToUppercase! !

!StringGenius methodsFor: 'converting' stamp: 'NR 11/11/2019 16:44:40'!
vowels: aWord
	
	^aWord select: [:letter | letter isVowel]! !

!StringGenius methodsFor: 'converting' stamp: 'NR 6/24/2021 19:16:17'!
words: aSentence
	
	^(self removeSpecialCharacters:aSentence) substrings! !


!classDefinition: #StringsServicesRestInterface category: 'StringsServicesServer'!
Object subclass: #StringsServicesRestInterface
	instanceVariableNames: 'webServer port stringGenius'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'StringsServicesServer'!

!StringsServicesRestInterface methodsFor: 'enabling services' stamp: 'NR 6/24/2019 06:51:52'!
destroy
	
	webServer ifNotNil:[webServer destroy].! !

!StringsServicesRestInterface methodsFor: 'enabling services' stamp: 'NR 6/23/2021 20:38:01'!
startListening
	
	webServer startListener.

	^'Listening on port: ', self port asString.
	! !

!StringsServicesRestInterface methodsFor: 'enabling services' stamp: 'NR 11/11/2019 15:54:20'!
stopListening
	
	webServer stopListener.
	
	^'Stopped listening from port: ', self port asString! !


!StringsServicesRestInterface methodsFor: 'initialization' stamp: 'NR 6/24/2021 19:18:02'!
initializeWith: aPortNumber
	
	stringGenius := StringGenius new.
	
	port:= aPortNumber.
	
	webServer := WebServer new listenOn: self port.
	
	webServer addService: '/quote' action:[:request |	
		
		request send200Response: (self sayRandomQuote)].
	
	webServer addService: '/words' action:[:request | |wordsAsJson sentence words |
		
		[sentence := (request fields at:'sentence').
		words := stringGenius words: sentence.
		wordsAsJson:= WebUtils jsonEncode: (words).
		request send200Response: (wordsAsJson)
		 ] 
		on: Error 
		do: [ :anError |
			request send400Response: (anError messageText) ]].
	
	webServer addService: '/firstLetter' action:[:request | |letterAsJson word letter |
		
		[word := (request fields at:'sentence').
		letter := stringGenius firstLetter: word.
		letterAsJson:= WebUtils jsonEncode: (letter asString).
		request send200Response: (letterAsJson)
		 ] 
		on: Error 
		do: [ :anError |
			request send400Response: (anError messageText) ]].
	
	webServer addService: '/vowels' action:[:request | |vowelsAsJson word vowels |
		
		[word := (request fields at:'sentence').
		vowels := stringGenius vowels: word.
		vowelsAsJson:= WebUtils jsonEncode: (vowels).
		request send200Response: (vowelsAsJson)
		 ] 
		on: Error 
		do: [ :anError |
			request send400Response: (anError messageText) ]].
	
	webServer addService: '/toUppercase' action:[:request | |upperCasedWordAsJson word upperCasedWord |
		
		[word := (request fields at:'sentence').
		upperCasedWord := stringGenius toUppercase: word.
		upperCasedWordAsJson:= WebUtils jsonEncode: (upperCasedWord).
		request send200Response: (upperCasedWordAsJson)
		 ] 
		on: Error 
		do:  [ :anError | request 
			request send400Response: (anError messageText)]].
! !

!StringsServicesRestInterface methodsFor: 'initialization' stamp: 'NR 11/11/2019 17:19:18'!
port
	"Use a random port to minimise chances of concurrently running test suites clashing."
	"^ port
		ifNil: [port := (10000 to: 50000) atRandom]"
	
	^port ifNil: [port:=8080].
	
	! !


!StringsServicesRestInterface methodsFor: 'private' stamp: 'NR 6/23/2021 20:29:59'!
quoteList
	
	^OrderedCollection with: 'You should have gone for the head' with: 'I Love you 3000!!' with: 'I am Groot!!' with: 'For All Time, Allways' with: 'I am inevitable...' with: 'Because Im Baaaatman!!'
	
	! !

!StringsServicesRestInterface methodsFor: 'private' stamp: 'NR 6/23/2021 20:33:19'!
sayRandomQuote
	| quotes |
	
	quotes := self quoteList.
	
	^quotes at: (quotes size atRandom).
	! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

!classDefinition: 'StringsServicesRestInterface class' category: 'StringsServicesServer'!
StringsServicesRestInterface class
	instanceVariableNames: ''!

!StringsServicesRestInterface class methodsFor: 'as yet unclassified' stamp: 'NR 11/11/2019 15:43:02'!
listeningOn: aPortNumber

	^self new initializeWith: aPortNumber.! !
