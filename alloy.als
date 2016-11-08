open util/boolean

sig CreditCard {}

sig DrivingLicence {}

sig MailAddress {}

abstract sig ClientState{}

sig DismountedClient extends ClientState{}

sig DrivingClient extends ClientState{}

sig OnBreakClient extends ClientState{}

sig ReservingClient extends ClientState{}

sig Person{
code: Int,
mail: one MailAddress,
position: lone Position,
} {
code>0
}

sig Client extends Person{
card: one CreditCard,
licence: one DrivingLicence,
state: one ClientState,
//currentReservation: lone Reservation
}

sig Assistant extends Person{}
//codici univoci e diversi tra clienti e assistant. mail univoche tra persone. se reserving deve avere reservation

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
battery: Int,
lock: Bool,
position: one Position,
state: one CarState,
reservation: lone Reservation,
} {
code>0
battery>=0
battery<=100
}

sig Discount{
percentage:Int,
}
{
percentage>=0
percentage<=100
}

sig Course {
timeStart: one Date,
timeEnd: one Date,
cashAmount: Int,
discounts: set Discount,
client: one Client,
car: one Car,
startPosition: one Position,
endPosition: one Position,
} {
cashAmount>0
}

sig Reservation{
reservationCountdown:Int,
courtesyCountdown:Int,
client: one Client,
car: one Car,
}
{
reservationCountdown>=0
reservationCountdown<=3600
courtesyCountdown>=0
courtesyCountdown<=300
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

pred show{}
run show for 3
