extends Node2D

var testing : bool = false
var founder : bool = false

var daysOfMonths = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]

const minuteMark : int = 60
const hourMark : int = 60

var lastLoginDict = Time.get_date_dict_from_system()
var timeDict
var weeklyFocusTotal : int = 0
var weeklyFocusPB : int = 0
var dailyFocusTotal : int = 0
var thisWeekDailyTotals = [0, 0, 0, 0, 0, 0, 0]
var pastWeekDailyTotals = {}
var pastWeeks = []
var totalWeeks : int = 0
var longestFocusTime : int = 0

var justLoaded : bool = true
var showTransition : bool = true

var curtainsOpen : bool = true
var fireplaceOn : bool = true
var lightLevel : int = 2
var audioMuted : bool = false

var totalFocusTime : int = 0
var username : String
var dateJoined = Time.get_date_dict_from_system()
var colourScheme : int = 0

var projects = [null]
var completedProjects = []
var totalCurrentProjects : int = 0
var totalCompletedProjects : int = 0

var gifts = [] #3 gifts per animal, this array stores the number of each gift you have
var giveNewGift : bool = false
var newGiftRarity : int


var colourSchemes : int = 0

var rng = RandomNumberGenerator.new()

var animals = ["dog1", "dog2", "dog3", "cat1", "guinea_pig1", "bear1", "rabbit", "dog4", "bird1", "snail"]
var numAnimals = animals.size()
var animalSounds = ["dog_bark1", "dog_bark2", "dog_bark3", "cat_meow1", "guinea_pig_squeak1", "bear_roar1", "rabbit_squeak", "dog_bark4", "bird_tweet1", "snail_sludge"]
var walkSpeeds = [0.75, 1, 1.1, 0.6, 0.3, 0.8, 0.75, 1, 1, 0.1]

var skinColours = []
var hairColours = []

var skinColour : int = 0
var hairColour : int = 0

var hat : int = 0
var hair : int = 0
var face : int = 0
var jumper : int = 0
var neckwear : int = 0
var handwear : int = 0
var walking_stick : int = 0
var trousers : int = 0

var cosmetics = [hat, hair, face, jumper, neckwear, handwear, walking_stick, trousers]

var animalParts = {
	"dog1" : ["Legs", "Body", "Pattern"],
	"dog2" : ["Legs", "Body", "Pattern"],
	"dog3" : ["Legs", "Body", "Pattern"],
	"cat1" : ["Legs", "Body", "Eyes"],
	"guinea_pig1" : ["Legs", "Body", "Pattern"],
	"bear1" : ["Legs", "Body", "Pattern"],
	"rabbit" : ["Legs", "Body", "Pattern"],
	"dog4" : ["Legs", "Body", "Pattern"],
	"bird1" : ["Wings", "Body", "Pattern"],
	"snail" : ["Body", "Shell", "Pattern"]
}



var animalGifts = {
	"dog1" : ["Tennis Ball", "Pinecone", "Seasonal Jumper"], #tilly / staffy
	"dog2" : ["Stick", "Pebble", "Basic Walking Stick"], #flora / cockerspaniel
	"dog3" : ["Daisy", "Toy Chicken", "Necklace Charm"], #sonny / labrador
	"cat1" : ["Feather", "Beetle", "Jade Ring"],  #ninki / cat
	"guinea_pig1" : ["Broccoli", "Blueberry", "Top Hat"], #guinea pig
	"bear1" : ["Blackberry", "Beehive", "Bear Walking Stick"], #bear
	"rabbit" : ["Carrot", "Celery", "Ruby Ring"],
	"dog4" : ["Chew Toy", "Ladybird", "Burger Jumper"],
	"bird1" : ["Berries", "Egg", "Nest Hat"],
	"snail" : ["Slime", "Burger", "Bow Tie"]
}

var giftDescriptions = {
	"Tennis Ball" : "Used for fetch. It's a bit slobbery...",
	"Pinecone" : "Fell from a pine tree. Smells nice." , 
	"Seasonal Jumper" : "Can be worn. Makes you feel very autumnal.",
	"Stick" : "Broke from a tree. Smells of sticks.",
	"Pebble" : "A lovely smooth oval pebble. Very nice.",
	"Basic Walking Stick" : "Can be equipped to walk with. Makes you feel like a wizard.",
	"Daisy" : "A fresh flower. Can be put in a boquet.",
	"Toy Chicken" : "A great gift for any dog.",
	"Necklace Charm" : "Can be worn. Seems like it has some backstory to it.",
	"Feather" : "From a colourful green bird. Shines a little bit.", 
	"Beetle" : "A shiny green beetle. His name is Small.",
	"Jade Ring" : "Can be worn. Makes you feel royal.",
	"Broccoli" : "A tasty broccoli.",
	"Blueberry" : "A shiny, juicy blueberry. Yum.",
	"Top Hat" : "Can be worn. Makes you look fancy.",
	"Blackberry" : "A sweet and tangy blackberry. Scrummy.",
	"Beehive" : "I think there are still bees living here...",
	"Bear Walking Stick" : "Can be equipped to walk with. Looks super cool.",
	"Carrot" : "Help you to see in the dark (maybe).",
	"Celery" : "Crunchy. Shaped like a slide for ants.",
	"Ruby Ring" : "Can be worn. Looks very shiny.",
	"Chew Toy" : "A chewy toy for a dog. Very slobbery...",
	"Ladybird" : "A little ladybird! Her name is Wendy.",
	"Burger Jumper" : "Can be worn. It's a wooly jumper with a... burger on it?",
	"Berries" : "A few lovely red berries. Yummy.",
	"Egg" : "A freshly laid egg!",
	"Nest Hat" : "Can be worn. 'Hand' made by the bird just for you!",
	"Slime" : "Sticky and gooey slime.",
	"Burger" : "A burger! Where did it find this?",
	"Bow Tie" : "Can be worn. Makes you look fancy."
}


var giftProbabilities = {
	600 : [0, 0, 0], #10 mins
	1800 : [90, 10, 0], #30 mins
	3600 : [75, 24, 1], #1 hr
	5400 : [60, 38, 2], #1.5 hrs
	7200 : [50, 46, 4], #2 hrs
	9000 : [45, 50, 5], #2.5 hrs
	10800 : [30, 60, 10], #3 hrs
	14400 : [15, 70, 15], #4 hrs
	18000 : [0, 80, 20], #5 hrs
	21600 : [0, 75, 25]  #6 hrs
}



func Generate_Random(min : int, max : int) -> int:
	return rng.randi_range(min, max)

func Generate_Random_Float(min : float, max : float) -> float:
	return rng.randf_range(min, max)


func save() -> Dictionary:
	var save_dict = {
		"founder" : founder,
		"username" : username,
		"totalFocusTime" : totalFocusTime, 
		"totalCurrentProjects" : totalCurrentProjects,
		"totalCompletedProjects" : totalCompletedProjects,
		"colourScheme" : colourScheme,
		"gifts" : gifts,
		"curtainsOpen" : curtainsOpen,
		"fireplaceOn" : fireplaceOn,
		"lastLoginDict" : Time.get_date_dict_from_system(),
		"weeklyFocusTotal" : weeklyFocusTotal,
		"weeklyFocusPB" : weeklyFocusPB,
		"skinColour" : skinColour,
		"hairColour" : hairColour,
		"cosmetics" : cosmetics,
		"audioMuted" : audioMuted,
		"pastWeeks" : pastWeeks,
		"thisWeekDailyTotals" : thisWeekDailyTotals,
		"pastWeekDailyTotals" : pastWeekDailyTotals,
		"dailyFocusTotal" : dailyFocusTotal,
		"totalWeeks" : totalWeeks,
		"dateJoined" : dateJoined,
		"longestFocusTime" : longestFocusTime
	}
	return save_dict


func Convert_Time(totalTime : int) -> String:
	#convert elapsed seconds into hours, minutes, seconds format
	var totalSeconds : int = snappedi(totalTime, 0.1)
	var seconds : int
	var minutes : int
	var hours : int
	
	seconds = totalSeconds % 60
	minutes = (totalSeconds / 60) % 60
	hours = (totalSeconds / 60) / 60
	
	#creates time string 00:00:00
	return Pad_Time(hours) + ":" + Pad_Time(minutes) + ":" + Pad_Time(seconds)

func Pad_Time(num: int) -> String:
	#if number passed is less than 10, add a '0' in front
	if num < 10:
		return "0" + type_convert(num, TYPE_STRING)
	else:
		return type_convert(num, TYPE_STRING)



#to do:
	#then draw profile pictures for each animal with consistent layers
	
	#then draw gifts and hook up to gift scene
