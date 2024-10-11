// A JavaScript Program to detect cycle in a graph

class DependencyGraph {
	nodes = [];
	events;
	string_prolog = ":- table process_rel/2, rel/2, rel/3, mb_order/3, onen_order/3, onen_mb_order/2, nn_rel/3, crown_rel_transitive/3.\n";
	session;

	constructor(nodes, draw_edges, events) {
		this.nodes = nodes;
		this.events = events;
	}

	async load_code() {
		var code = "";
		await fetch('msc.pl')
		.then(response => response.text())
		.then((data) => {
			this.string_prolog += this.make_string(nodes, draw_edges, events)+data;
		})
	}

	async initalize() {
		await this.load_code();
		
		let Module = {
			locateFile: (file) => file
		}
		const options = {
		// Provide options for customization
		};


		let module = await SWIPL(options);

		this.session = module.prolog;

		await this.session.load_string(this.string_prolog);

	}

	make_string(nodes, draw_edges, events) {
		let list_event = [];
		let events_prolog = "";
		let receive = false;
		let process_rel = "";

		for (const message_event of draw_edges) {
			let n1 = getNodeById(message_event.source);
			let n2 = getNodeById(message_event.target);
			let match = !message_event.dashed;
			let p1 = n1.p;
			let p2 = n2.p;
			let msg = n1.m;
			n1.code = "s(p" + p1 + ",p" + p2 + ",m" + msg + ")";
			events_prolog += "event(" + n1.code + "). \n";
			if (match) {
				receive = true;
				n2.code = "r(p" + p1 + ",p" + p2 + ",m" + msg + ")";
				events_prolog += "event(" + n2.code + "). \n";
			} else {
				n2.code = "";
			}
		}

		if (events_prolog == "") {
			events_prolog = "event(s(_,_,_)) :- fail.\n";
		}
		if (!receive) {
			events_prolog += "event(r(_,_,_)) :- fail.\n";
		}

		var previous = NaN;
		for (const procs of events) {
			previous = NaN;
			for (const id_event of procs) {
				if (previous >= 0) {
					if (getNodeById(previous).code != "" && getNodeById(id_event).code != "") {
						process_rel += "process_rel(" + getNodeById(previous).code + "," + getNodeById(id_event).code + ").\n";
					} 
						
				}
				previous = id_event;
			}
		}
		if (process_rel == "") {
			process_rel = "process_rel(_,_) :- fail.\n";
		}
		
		return events_prolog + process_rel;
	}


	async isMSC() {
		var result = [false, ""];
		
		var query_obj = this.session.query("asy(A).").once();
		if (query_obj.success) {
			result = [false, query_obj["A"]];
		} else {
			result = [true, ""];
		}

		console.log("asy : " + result[0] + "\n");
		return result;
	}
	async ispp() {
		var result = [false, ""];

		var query_obj = this.session.query("pp(A).").once();
		if (query_obj.success) {
			result = [false, query_obj["A"]];
		} else {
			result = [true, ""];
		}

		console.log("pp : " + result[0] + "\n");
		return result;
	}
	async isco() {
		var result = [false, ""];
		
		var query_obj = this.session.query("co(A).").once();
		if (query_obj.success) {
			result = [false, query_obj["A"]];
		} else {
			result = [true, ""];
		}

		console.log("co : " + result[0] + "\n");
		return result;
	}
	async ismb() {
		var result = [false, ""];
		
		var query_obj = this.session.query("mb(A).").once();
		if (query_obj.success) {
			result = [false, query_obj["A"]];
		} else {
			result = [true, ""];
		}

		console.log("mb : " + result[0] + "\n");
		return result;
	}
	async isonen() {
		var result = [false, ""];
		
		var query_obj = this.session.query("onen(A).").once();
		if (query_obj.success) {
			result = [false, query_obj["A"]];
		} else {
			result = [true, ""];
		}

		console.log("onen : " + result[0] + "\n");
		return result;
	}
	async isnn() {
		var result = [false, ""];
		
		var query_obj = this.session.query("nn(A).").once();
		if (query_obj.success) {
			result = [false, query_obj["A"]];
		} else {
			result = [true, ""];
		}

		console.log("nn : " + result[0] + "\n");
		return result;
	}
	async isrsc() {
		var result = [false, ""];
		
		var query_obj = this.session.query("rsc(A).").once();
		if (query_obj.success) {
			result = [false, query_obj["A"]];
		} else {
			result = [true, ""];
		}

		console.log("rsc : " + result[0] + "\n");
		return result;
	}
}
