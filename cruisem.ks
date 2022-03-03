// This program gains altitude and it maintains it
// Switch to 0.

clearscreen.
print("Starting cruiser vM . . .").

function aoa {
	local srfVel is VXCL(SHIP:FACING:STARVECTOR,SHIP:VELOCITY:SURFACE).
	return VANG(SHIP:FACING:FOREVECTOR,srfVel).
}

SAS off.
RCS on.
lights on.
set tVal to 1.
lock throttle to tVal.

set hdg to target:heading.			// Heads to target
set pit to 90.
set pitRate to 2.					// PITCH RATE
set targetAltitude to 15000.		// TALT
set tSpeed to 1100.
set speedError to 40.
set planetRadius to 600000.

clearscreen.

// Take Off sequence
stage.

print("-- Take Off sequence --") at (10,1).
print("SRB status:      ACTIVE") at (5,4).
print("Main engine:     INACTIVE") at (5,5).

set cruise to False.
set SRBs to True.

LIST ENGINES IN engList.
SET SRB TO engList[0].

until cruise {

	set speedRecord to SHIP:AIRSPEED.

	wait 1.

	set acceleration to SHIP:AIRSPEED - speedRecord.

	if acceleration < 0 {
		set acceleration to acceleration * -1.
	}

	set hdg to target:heading.
	if pit > pitRate {
		set pit to pit - pitRate.
	}

	lock steering to heading (hdg,pit).

	if SRB:thrust <= 0.01 and SRBs{
		stage.
		print("SRB status:      JETTISONED    ") at (5,4).
		print("Main engine:     ACTIVE     ") at (5,5).
		set SRBs to False.
	}
	print("AoA:             " + round(aoa, 1) + "°   ") at (5,6).
	print("Pitch:           " + round(pit, 1) + "°    ") at (5,7).
	print("Acceleration:    " + round(acceleration/9.81, 2) + " g   ") at (5,8).

	if altitude >= targetAltitude{	// NRMv
		set cruise to True.
		set pit to 0.
	}
	if verticalspeed < 1{			// EMGx
		set cruise to True.
		set pit to 10.
	}
}

// Cruise
set descent to False.
set stable to False.

clearscreen.

set tVal to 0.25.

until stable {
	if verticalspeed > -1 and verticalspeed < 1{
		set targetAltitude to altitude.
		set stable to True.
	}
	print("Stabilizing . . .") at (10,1).
}

set pit to 20.

until descent {
	// ugly math
	set phi1 to latitude.
	set phi2 to target:latitude.
	set deltaPhi to (latitude - target:latitude).
	set deltaLam to (longitude - target:longitude).

	set a to sin(deltaPhi/2.0)^2 + cos(phi1) * cos(phi2) * sin(deltaLam/2.0)^2.

	set c to 2 * arctan2(sqrt(a),sqrt(1-a)) * constant:pi/180.0.

	set distance to c * planetRadius.



	set hdg to target:heading.

	if verticalspeed < -1		{
		set pit to pit + 0.1.
	}
	else if verticalspeed > 1	{
		set pit to pit - 0.1.
	}
	if pit > 16 {
		set pit to 15.
	}
	else if pit < 1 {
		set pit to 2.
	}

	lock steering to heading (hdg,pit).
	lock throttle to tVal.

	print("-- CRUISE --") at (10,1).
	print("MACH:            " + round(((SHIP:AIRSPEED) / 343), 3)) 				at (5,4).
	print("DISTANCE:        " + round(distance/1000) + " km    ") 				at (5,5).
	print("THROTTLE:        " + round(tVal * 100, 1) + " %    ") 				at (5,6).
	print("AoA:             " + round(aoa, 1) + "°    ") 						at (5,7).
	print("ESTIMATED TIME:  " + (round(distance / tSpeed)) + " s    ") 			at (5,8).


	if TARGET:DISTANCE < targetAltitude * 3{
		set descent to True.
	}

}
clearscreen.

print("-- TERMINAL PHASE --") at (10,1).

lock steering to heading (hdg,70).

wait 10.

set tVal to 0.

lock steering to target:position.

wait 5.

set pit to (90 - vectorangle(UP:FOREVECTOR, FACING:FOREVECTOR)).	// sets to current pitch

until False{

	if TARGET:DISTANCE < targetAltitude{
		lock steering to target:position.
		set tVal to 1.
	}
	else {
		set pit to pit + 0.01.
		lock steering to heading (hdg,pit).
	}

	lock throttle to tVal.

	print("-- TERMINAL PHASE --") at (10,1).
	print("MACH:            " + round(((SHIP:AIRSPEED) / 343), 3)) 		 				at (5,4).
	print("DISTANCE:        " + round(TARGET:DISTANCE) + " m    ") 						at (5,5).
	print("THROTTLE:        " + round(tVal * 100, 1) + " %    ") 						at (5,6).
	print("AoA:             " + round(aoa, 1) + "°    ") 								at (5,7).
	print("Pitch:           " + round(pit, 1) + "°    ") 								at (5,8).
}
