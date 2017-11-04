// source_vs_fp_0.v

// Generated using ACDS version 17.0 602

`timescale 1 ps / 1 ps
module source_vs_fp_0 (
		output wire [3:0] source  // sources.source
	);

	altsource_probe_top #(
		.sld_auto_instance_index ("YES"),
		.sld_instance_index      (0),
		.instance_id             ("NONE"),
		.probe_width             (0),
		.source_width            (4),
		.source_initial_value    ("A"),
		.enable_metastability    ("NO")
	) in_system_sources_probes_0 (
		.source     (source), // sources.source
		.source_ena (1'b1)    // (terminated)
	);

endmodule
