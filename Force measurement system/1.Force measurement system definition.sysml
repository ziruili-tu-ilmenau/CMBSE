package ForceMeasurementSystem_v1_Definition{
	import ISQ::*;
	import SI::*;
	import ScalarValues::*;
	import OEMGeneralDefinition::*;
	package FMSPartDefinition{
		import FMSPortDefinition::*;
		import FMSSignalDefinition::*;
		part def def_FMS:>GeneralPartDefinition::def_OverallSystem{
			attribute Loadcellnumber:Real;
			exhibit state st_MeasuringSystem :FMSStateDefinition::def_MeasuringSystemState parallel{
				state st_Measuring{
					state st_On{
						entry action initial;
						state st_Standby;                    
						state st_Measurement{
							do act_ForceMeasurement;
						}
						transition  initial then st_Standby;
						transition standby_to_Measurement
							first st_Standby
							accept measureCmd
							then st_Measurement;
						transition st_Measurement then st_Standby;
					}
					state st_Off;
				transition on_to_off
					first st_On
					accept SystemOffSignal
					then st_Off;
				transition off_to_on
					first st_Off
					accept SystemOnSignal
					then st_On;
					}
               	state st_CheckingMonitor{}
			}
		}
		part def def_LoadCell:>GeneralPartDefinition::def_LoadCell{
			port port_messinfo:def_port_MeasuringInfo_v1;
			}
		part def def_MeasuringRing:>GeneralPartDefinition::def_MeasuringRing{}
		part def def_EnergySystem:>GeneralPartDefinition::def_EnergySystem{}
	}
	package FMSPortDefinition{
		port def def_port_MeasuringInfo_v1:>GeneralPortDefinition::def_port_MeasuringInfo;
		port def def_port_Energy_v1:>GeneralPortDefinition::def_port_Energy;
		port def def_port_Mass_v1:>GeneralPortDefinition::def_port_Mass;
		port def def_port_Temperature_v1:>GeneralPortDefinition::def_port_Temperature;
		}
	package FMSSignalDefinition{
		attribute def SystemOffSignal;
		attribute def SystemOnSignal;
		attribute def measureCmd;
	}
	package FMSInterfaceDefinition{
		interface def def_EnergyInterface:>GeneralInterfaceDefinition::def_EnergyInterface;
		interface def def_TemperatureInterface:>GeneralInterfaceDefinition::def_TemperatureInterface;
	}
	package FMSStateDefinition{
		state def def_MeasuringSystemState;
	}
	package FMSItemDefinition{
            item def def_MeasuringObject{
				attribute ObjectMass:>ISQ::mass;
			}
        }
	package FMSActionDefinition{
		action def def_act_provideEnergy{
			out voltageEnergy:>ISQ::voltage;
		}
		action def def_act_ForceMeasurement:>GeneralActionDefinition::def_act_ForceMeasurement{
			in voltageEnergy:>ISQ::voltage;
			in item measuringObject:FMSItemDefinition::def_MeasuringObject;
			out messresult:>ISQ::mass;
		}
	}
	package FMSRequirementDefinition{
		requirement def def_TemperatureRequirement:>GeneralRequirementDefinition::def_TemperatureRequirement;
        requirement def def_AccuracyRequirement:>GeneralRequirementDefinition::def_AccuracyRequirement;
        requirement def def_MeasurementRequirement:>GeneralRequirementDefinition::def_MeasurementRequirement; 
	}

}
