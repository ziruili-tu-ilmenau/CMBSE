library package AllocationExtension{
	public import SysML::*;
	public import Metaobjects::SemanticMetadata;

	metadata def FullyMatched :> SemanticMetadata {
	    :>> baseType = AllocationUsage meta SysML::AllocationUsage;
	}
	metadata def FullyUnMatched :> SemanticMetadata {
	    :>> baseType = AllocationUsage meta SysML::AllocationUsage;
	}
	metadata def RequireModification :> SemanticMetadata {
	    :>> baseType = AllocationUsage meta SysML::AllocationUsage;
	}
	metadata def RequireComplement :> SemanticMetadata {
	    :>> baseType = AllocationUsage meta SysML::AllocationUsage;
	}
}