open util/boolean

//-----------------------------------------------------------SIGNATURES-------------------------------------------------------//

abstract sig ClientState{}

sig DismountedClient extends ClientState{}

sig DrivingClient extends ClientState{}

sig OnBreakClient extends ClientState{}

sig ReservingClient extends ClientState{}

abstract sig Battery{}

sig LowBattery extends Battery{} //minore del 20%

sig HighBattery extends Battery{}

abstract sig Person{
code: Int,
position: lone Position,
} {
code>0
}

sig Client extends Person{
state: one ClientState,
currentReservation: lone Reservation,
currentCourse: lone Course
}

sig Assistant extends Person{}

sig Position 
{
x: Int, 
y: Int,
} {
x>0
y>0
}

abstract sig CarState {}

sig OnBreakCar extends CarState{}

sig AvailableCar extends CarState{}

sig NonAvailableCar extends CarState{}

sig OnCourseCar extends CarState{}

sig ReservedCar extends CarState{}

sig Car {
code: Int,
battery: Battery,
lock: Bool,
position: one Position,
state: one CarState,
reservation: lone Reservation,
course: lone Course,
} {
code>0
}

sig Course {
client: one Client,
car: one Car,
startPosition: one Position,
} 

sig Reservation{
client: one Client,
car: one Car,
}

sig ParkStation {
code: Int,
position: one Position,
rechargers: set Recharger,
} {
#rechargers >0
code>=0}

sig Recharger {
code: Int,
occupied: Bool,}{
code>=0
}

one sig SafeAreas {
areas: set Position,
}

//---------------------------------------------------------------FACTS-----------------------------------------------------------//

//the person code are unique
fact personCodeUnique {
all p1, p2: Person | (p1 != p2) implies p1.code != p2.code
}

//positions are unique
fact uniquePosition {
all p1,p2: Position | p1 != p2 implies p1.x != p2.x or p1.y != p2.y
}

//there are no multiple reservations for a client
fact noTwoReservationWithSameClient{
all r1, r2: Reservation | (r1 != r2) implies r1.client != r2.client
}

//there are no multiple  reservations for a car
fact noTwoReservationWithSameCar{
all r1, r2: Reservation | (r1 != r2) implies r1.car != r2.car
}

//there is a unique driver for each course
fact noTwoDriverForCourse{
all c1, c2: Course | c1 != c2 implies (c1.client != c2.client)
}

//there is a unique car for each course
fact noTwoCarForCourse{
all c1, c2: Course | c1 != c2 implies (c1.car != c2.car)
}

//there are no car with same position
fact noTwoCarWithSamePosition {
all c1,c2: Car | (c1 != c2) implies c1.position != c2.position
}

//relation between client and course
fact clientCourseDoubleRelation {
all cl: Client, co: Course |  cl.currentCourse = co iff co.client = cl 
}

//relation between car and course
fact carCourseDoubleRelation {
all ca: Car, co: Course |  ca.course=co iff co.car=ca 
}

//relation between client and reservation
fact clientReservationDoubleRelation {
all cl: Client, r: Reservation | cl.currentReservation=r iff r.client=cl
}

//relation between car and reservation
fact carReservationDoubleRelation {
all ca: Car, r: Reservation | ca.reservation=r iff r.car=ca 
}

//a client is in Reserving state if and only if he has a reservation and no course
fact consistencyOfClientReservationState {
all c: Client | c.state=ReservingClient iff (#c.currentReservation=1 and #c.currentCourse=0)
}

//a car is in Reserved state if and only if it has a reservation and no course
fact consistencyOfCarReservationState {
all c: Car | c.state=ReservedCar iff (#c.reservation=1 and #c.course=0)
}

//a client is in Driving or OnBreak state if and only if he has a course and no reservation
fact consistencyOfClientCourseState {
all c: Client | (c.state=DrivingClient or c.state=OnBreakClient) iff (#c.currentReservation=0 and #c.currentCourse=1)
}

//a car is in OnCourse or OnBreak state if and only if he has a course and no reservation
fact consistencyOfCarCourseState {
all c: Car | (c.state=OnCourseCar or c.state=OnBreakCar) iff (#c.reservation=0 and #c.course=1)
}

//for all courses the cars and clients associated are OnCourse/Driving or OnBreak states
fact stateOfClientAndCarInCourse{
all c: Course |  (c.client.state = DrivingClient and c.car.state = OnCourseCar) or 
						(c.client.state = OnBreakClient and  c.car.state = OnBreakCar)
}

//car not on course are locked
fact carNotOnCourseLocked {
all c: Car | c.state = OnCourseCar iff c.lock = False
}

//battery discharged => non available
fact  carDischargeNonAvailable {
all c: Car | c.battery=LowBattery 
				implies 
				( c.state = NonAvailableCar or c.state = OnCourseCar or c.state = OnBreakCar) 
}

//reserved/available car => battery not discharged
fact carReservedAndAvailableWithBatteryCharged{
all c: Car | (c.state = ReservedCar or c.state = AvailableCar)
				 implies
				 c.battery = HighBattery
}

//there aren't park stations with same position
fact noTwoParkStationWithSamePosition {
all p1,p2: ParkStation | p1 != p2 implies p1.position != p2.position
}

//park station code are unique
fact parkStationCodeUnique {
all p1,p2: ParkStation | p1 != p2 implies p1.code != p2.code
}

//recharger code unique in each park station
fact rechargerCodeUniqueInParkStation {
all r1, r2: Recharger, p: ParkStation | ( r1 in p.rechargers and r2 in p.rechargers ) implies r1.code = r2.code
}

//there aren't two park station with the same recharger
fact noParkStationWithSameRecharger {
all p1, p2: ParkStation, r: Recharger | ( p1 != p2 ) implies !(r in p1.rechargers and r in p2.rechargers)
}

//all car in available or non available or on break or reserved state are parked in a safe area
fact carAvailableAndOnBreakInSafeArea {
all c: Car | some  s: SafeAreas |
				(c.state = AvailableCar or c.state = NonAvailableCar or c.state = OnBreakCar or c.state = ReservedCar)
				implies
				c.position in s.areas
}

//there are only battery related to cars
fact batteryInACar
{
all b: Battery | one c:Car | c.battery=b
}

//there are only carState related to cars
fact onlyStatesReletedToCar
{
all cs:CarState | some c:Car | c.state=cs
}

//there are only clientState related to client
fact onlyStatesReletedToClient
{
all cs:ClientState | some c:Client | c.state=cs
}

//there are only recharger related to park station
fact onlyRechargerRelatedToParkStation
{
all r: Recharger | one p: ParkStation | r in p.rechargers
}

//-----------------------------------------------------------PREDICATES-------------------------------------------------------//

pred reserveACar[cl:Client, ca:Car, r:Reservation ]{
 r in cl.currentReservation and ca in r.car
}

pred inDriving[cl:Client, ca:Car, co:Course]{
cl in co.client and ca in co.car
}


//----------------------------------------------------------ASSERTION--------------------------------------------------------//

//check if there are setted correctly the states of the client and the car in a reservation 
assert correctStatesReservation
{
	all cl:Client, ca:Car, r: Reservation| reserveACar[cl, ca, r] implies (cl.state=ReservingClient and ca.state=ReservedCar)
}

check correctStatesReservation

//check that doesn't exsist cars or clients both in course and in reservation
assert noClientAndCarOnCourseAndOnReservation
{
	all cl:Client, ca:Car, co:Course, r:Reservation| inDriving[cl, ca, co] implies (r.client!=cl and r.car!=ca)
}

check noClientAndCarOnCourseAndOnReservation

//check that there aren't car parked (and so in available or non-available or onbreak or reserved state) and unlocked
assert noParkedCarUnlocked
{
	no c: Car| c.lock = False and
	(c.state = AvailableCar or c.state = NonAvailableCar or c.state = OnBreakCar or c.state = ReservedCar)
}

check noParkedCarUnlocked

//check that there are no car reserved or available with low battery
assert noAvailableOrReservedCarWithLowBattery
{
	no c: Car | 	(c.state = AvailableCar or c.state = ReservedCar) and c.battery = LowBattery
}

check noAvailableOrReservedCarWithLowBattery
/*
run reserveACar*/

//check that there are no reservation without car or client associated
assert noReservationWithoutClientOrCar
{
	no r: Reservation | #r.client=0 or #r.car=0
}

check noReservationWithoutClientOrCar

//check that there are no course without car or client associated
assert noCourseWithoutClientOrCar
{
	no c: Course| #c.client=0 or #c.car=0
}

check noReservationWithoutClientOrCar

//check that no car parked aren't in a safe area
assert noCarParkedOutOfSafeAreas
{
	no c: Car | all s: SafeAreas | c.position not in s.areas and (c.state = AvailableCar or c.state = NonAvailableCar or c.state = OnBreakCar or c.state = ReservedCar)
}

check noCarParkedOutOfSafeAreas

//predicate that shows a world that underlines reservation properties
pred showReservation
{
	#Reservation=1
	#ParkStation=1
	#Course=0
	#Car=1
	#Client=1
	#Recharger=1
}

run showReservation for 2  

//predicate that shows a world that underlines course properties
pred showCourse
{
	#Reservation=0
	#ParkStation=1
	#Course=1
	#Car=1
	#Client=1
}

run showCourse for 2

pred show{}

run show for 2 

