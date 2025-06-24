package LoadCellSolution{
    

    package Definition{
    	public import ScalarValues::*;
        public import ISQ::*;
        public import SI::*;
        public import Quantities::*;
		public import Partdefinition::*;
		public import PortDefinition::*;
        public import InterfaceDefinition::*;
        public import ItemDefinition::*;
        package Partdefinition{
            part def MeasuringSystem_def{
                attribute Loadcellnumber:Real;
                port port_OS_Temperature:port_Temperature_def;
                port port_OS_MeasuringInfo:port_MeasuringInfo_def;
            }
            part def loadcell_def{
                attribute weight :> ISQ::mass;
                attribute Tmax:>ISQ::temperature{
                    doc /*maximum working temperature of load cell */
                }
                attribute Tmin:>ISQ::temperature{
                    doc /*minimum working temperature of load cell */
                }
                attribute maximumCapacity:>ISQ::mass{
                    doc /*maximum measuring capacity of load cell */
                }
                attribute inputvoltage:>ISQ::voltage;
                port port_temperature:port_Temperature_def;
                port port_power:port_Power_def;
                port port_mass:port_Mass_def;
                port port_Measuringinfo:port_MeasuringInfo_def;
            }
            part def StrainGauge_def{
                attribute Material:String;
            }
            part def EnergySystem_def{
            	port port_OutputEnergy:~port_Power_def;
            }
        }
        package PortDefinition{            
            port def port_Temperature_def { 
                in Roomtemperature :> ISQ::temperature;
            }
            port def port_Power_def { 
                in inputVolt :> ISQ::voltage;
            }
            port def port_Mass_def {
                in item measuringObject;
            }
            port def port_MeasuringInfo_def { 
                millivolt :> scalarQuantities = ISQ::voltage*1000;
                out MessInfo :> millivolt;
            }
        }
        package InterfaceDefinition{
            interface def MessDataInterface_def{
	           	end p1:port_MeasuringInfo_def;
	            end p2:~port_MeasuringInfo_def;
	            flow p1.MessInfo to p2.MessInfo;
            }
            interface def PowerInterface_def{
	            end p1:port_Power_def;
	            end p2:~port_Power_def;
	            flow p2.inputVolt to p1.inputVolt;
            }
            interface def TemperatureInterface_def{
                end p1:port_Temperature_def;
                end p2:~port_Temperature_def;
                flow p2.Roomtemperature to p1.Roomtemperature;
            }
	    }
        package ItemDefinition{
            item def def_MeasuringObject{
                attribute ObjectMass:>ISQ::mass;
            }
        }
    }
    package LoadCellSolutionModel{
        public import Definition::*;
        package PartsTree{
            part MeasuringSystem_v1 : Partdefinition::MeasuringSystem_def{
                attribute num redefines Partdefinition::MeasuringSystem_def::Loadcellnumber=3;
                part loadcell_v1:loadcell_def{
                    attribute loadcellMass redefines mass=2[kg];
                    attribute  redefines inputvoltage=12[V];
                    attribute  loadcellCapacity redefines maximumCapacity=40[kg];
                    part 'Strain Gauge':Partdefinition::StrainGauge_def{
			 			attribute StrainGaugeMaterial:>>Material="Aluminium";
			 		}
                }
                part EnergySystem:Partdefinition::EnergySystem_def;
                interface energyInterface:InterfaceDefinition::PowerInterface_def
                    connect EnergySystem.port_OutputEnergy to loadcell_v1.port_power;
                interface TemperatureInterface:InterfaceDefinition::TemperatureInterface_def
                    connect MeasuringSystem_v1.port_OS_Temperature to loadcell_v1.port_temperature;
                interface MessDataInterface:InterfaceDefinition::MessDataInterface_def
                    connect loadcell_v1.port_Measuringinfo to MeasuringSystem_v1.port_OS_MeasuringInfo;
            }
        }
    }
}