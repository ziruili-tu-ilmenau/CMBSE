package ForceMeasurementSystem_v1_Definition{
	import ISQ::*;
	import SI::*;
	import ScalarValues::*;
	import OEMGeneralDefinition::*;
	package FMSPartDefinition{
		import FMSPortDefinition::*;
		import FMSSignalDefinition::*;
		part def FMS:>GeneralPartDefinition::OverallSystem{
			attribute Loadcellnumber:Real;
			exhibit state MeasuringSystemState parallel{
				state MeasuringState{
					state on{
						entry action initial;
						state standby;                    
						state Measurement{
							do ForceMeasurement;
						}
						transition  initial then standby;
						transition standby_to_Measurement
							first standby
							accept measureCmd
							then Measurement;
						transition Measurement then standby;
					}
					state off;
				transition on_to_off
					first on
					accept SystemOffSignal
					then off;
				transition off_to_on
					first off
					accept SystemOnSignal
					then on;
					}
               	state MaintanceState{}
			}
		}
		part def LoadCell:>GeneralPartDefinition::LoadCell{
			port messinfoPort:MeasuringInfoPort_v1;
			}
		part def MeasuringRing:>GeneralPartDefinition::MeasuringRing{}
		part def EnergySystem:>GeneralPartDefinition::EnergySystem{}
	}
	package FMSPortDefinition{
		port def MeasuringInfoPort_v1:>GeneralPortDefinition::MeasuringInfoPort;
		port def EnergyPort_v1:>GeneralPortDefinition::EnergyPort;
		port def MassPort_v1:>GeneralPortDefinition::MassPort;
		port def TemperaturePort_v1:>GeneralPortDefinition::TemperaturePort;
		}
	package FMSSignalDefinition{
		attribute def SystemOffSignal;
		attribute def SystemOnSignal;
		attribute def measureCmd;
	}
	package FMSInterfaceDefinition{
		interface def EnergyInterface:>GeneralInterfaceDefinition::EnergyInterface;
		interface def TemperatureInterface:>GeneralInterfaceDefinition::TemperatureInterface;
	}
	package FMSStateDefinition{
		state def MeasuringSystemState;
	}
	package FMSItemDefinition{
            item def MeasuringObject{
				attribute ObjectMass:>ISQ::mass;
			}
        }
	package FMSActionDefinition{
		action def provideEnergy{
			out voltageEnergy:>ISQ::voltage;
		}
		action def ForceMeasurement:>GeneralActionDefinition::ForceMeasurement{
			in voltageEnergy:>ISQ::voltage;
			in item measuringObject:FMSItemDefinition::MeasuringObject;
			out messresult:>ISQ::mass;
		}
	}
	package FMSRequirementDefinition{
		requirement def TemperatureRequirement:>GeneralRequirementDefinition::TemperatureRequirement;
        requirement def AccuracyRequirement:>GeneralRequirementDefinition::AccuracyRequirement;
        requirement def MeasurementRequirement:>GeneralRequirementDefinition::MeasurementRequirement; 
	}

}
