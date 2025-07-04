package LoadCellSolution{
    /*main difference is Load cell needs satisfy the temperature range to make sure the precise measuring, so the corresponding temperature port is necessary for both overall system and load cell*/
    
    /*the pull approach here shows new defined elements, some difference from naming or ontology, configured feature(which should aligned with WP6). But the modeling methodology and other difference is not shown here.*/
    package Tier1GeneralDefinition{
        /*package that contains the reuseable knowledge about system from supplier, is shareable, shouldn't contain IP knowledge */
        public import ScalarValues::*;
        public import ISQ::*;
        public import SI::*;
        public import Quantities::*;

        package 'Load Cell Part Definition'{
            public import 'Load Cell Port Definition'::*;
            part def def_loadcell{
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
                port port_temperature:def_port_Temperature;
                port port_power:def_port_Power;
                port port_mass:def_port_Mass;
                port port_Measuringinfo:def_port_MeasuringInfo;
            }
            part def def_StrainGauge{
                attribute Material:String;
            }
            part def def_Body{}
        }
        package 'Load Cell Port Definition'{
            /*some differences compared with OEM definitions*/
            port def def_port_Temperature { 
                in Roomtemperature :> ISQ::temperature;
                /*new port*/
            }
            port def def_port_Power { 
                in inputVoltage :> ISQ::voltage;
                /*same*/
            }
            port def def_port_Mass {
                /*item difference*/
                in item measuringObject:'Load Cell Item Definition'::def_MeasuringObject;
            }
            port def def_port_MeasuringInfo { 
                /*difference unit: millivolt vs. mass*/
                millivolt :> scalarQuantities = ISQ::voltage*1000;
                out MessData :> millivolt;
            }
        }	
        package 'Load Cell Item Definition'{
            item def def_MeasuringObject;
        }
        
    }
    package Definition{
        /*definitions specialized with both OEM and supplier definition*/
    	public import Tier1GeneralDefinition::*;
        public import OEMGeneralDefinition::*;
        /*import these two shareable definition pacakge, specialized them and build system model based on it. It's only one way to organize the model structure, but not necessary. In principle we can merge them together.*/
		public import Partdefinition::*;
		public import PortDefinition::*;
        public import InterfaceDefinition::*;
        public import ItemDefinition::*;
        package Partdefinition{
            part def def_OverallSystem:>OEMGeneralDefinition::GeneralPartDefinition::def_OverallSystem{
                /*based on the oem definition, add new feature for overall system to satisfy the requirement from loadcell*/
                attribute Loadcellnumber:Real;
                port port_Temperature:def_port_Temperature;
            }
            part def def_LoadCell:>Tier1GeneralDefinition::'Load Cell Part Definition'::def_loadcell;
            part def def_StrainGauge:>Tier1GeneralDefinition::'Load Cell Part Definition'::def_StrainGauge;
            part def def_EnergySystem:>OEMGeneralDefinition::GeneralPartDefinition::def_EnergySystem;
        }
        package PortDefinition{
            port def def_port_Energy:>Tier1GeneralDefinition::'Load Cell Port Definition'::def_port_Power;
            port def def_port_Temperature:>Tier1GeneralDefinition::'Load Cell Port Definition'::def_port_Temperature ;
        }
        package InterfaceDefinition{
            interface def def_MessDataInterface:>OEMGeneralDefinition::GeneralInterfaceDefinition::def_MessDataInterface;
            interface def def_EnergyInterface:>OEMGeneralDefinition::GeneralInterfaceDefinition::def_EnergyInterface;
            interface def def_TemperatureInterface{
                /*new defined interface*/
                end p1:def_port_Temperature;
                end p2:~def_port_Temperature;
                flow p2.Roomtemperature to p1.Roomtemperature;
            }
	    }
        package ItemDefinition{
            item def def_MeasuringObject:>Tier1GeneralDefinition::'Load Cell Item Definition'::def_MeasuringObject{
                attribute ObjectMass:>ISQ::mass;
            }
        }
    }
    package LoadCellSolutionModel{
        public import Definition::*;
        package PartsTree{
            part OverallSystem_v1 : Partdefinition::def_OverallSystem{
                attribute num redefines Partdefinition::def_OverallSystem::Loadcellnumber=3;
                part loadcell_v1:def_LoadCell{
                    attribute loadcellMass redefines mass=2[kg];
                    attribute  redefines inputvoltage=12[V];
                    attribute  loadcellCapacity redefines maximumCapacity=40[kg];
                    port  port_Energy : def_port_Energy;
                    part 'Strain Gauge':'Load Cell Part Definition'::def_StrainGauge{
			 			attribute StrainGaugeMaterial:>>Material="Aluminium";
                        /*difference here can also be the way to show features, like use string 'Aluminium', or other data type to relate the different material*/
			 		}
                }
                part EnergySystem:Partdefinition::def_EnergySystem;
                interface energyInterface:InterfaceDefinition::def_EnergyInterface
                    connect EnergySystem.port_OutputEnergy to loadcell_v1.port_Energy;
                interface TemperatureInterface:InterfaceDefinition::def_TemperatureInterface
                    connect OverallSystem_v1.port_Temperature to loadcell_v1.port_temperature;
                interface MessDataInterface:InterfaceDefinition::def_MessDataInterface
                    connect loadcell_v1.port_Measuringinfo to OverallSystem_v1.port_MeasuringInfo;
            }
        }
    }
}