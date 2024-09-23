// A JavaScript Program to detect cycle in a graph
var prolog_code = "process_rel(X,Z) :- process_rel(X,Y), process_rel(Y,Z).\n\
match(s(X,Y,Z), r(X,Y,Z)) :- event(s(X,Y,Z)), event(r(X,Y,Z)).\n\
rel(X,Y) :- process_rel(X,Y).\n\
rel(X,Y) :- match(X,Y).\n\
rel(X,Z) :- rel(X,Y), rel(Y,Z).\n\
\n\
%---ASY---\n\
envoie_correct :- event(s(X,X,_)),!, fail.\n\
envoie_correct.\n\
reception_correct :- event(r(X,Y,Z)), \\+event(s(X,Y,Z)), !, fail.\n\
reception_correct.\n\
cycle :- rel(X,X).\n\
\n\
asy :- \\+cycle, reception_correct, envoie_correct.\n\
\n\
%---P2P---\n\
cond_err_p2p(s(X,Y,M1), s(X,Y,M2)) :- match(s(X,Y,M1), R1), match(s(X,Y,M2), R2), process_rel(R2,R1), !.\n\
cond_err_p2p(S1, S2) :- \\+match(S1, _), match(S2, _), !.\n\
cond_err_p2p(_,_) :- !, fail.\n\
\n\
err_p2p :- event(s(X,Y,M1)), event(s(X,Y,M2)), M1\\=M2, process_rel(s(X,Y,M1), s(X,Y,M2)), cond_err_p2p(s(X,Y,M1),s(X,Y,M2)).\n\
\n\
p2p :- asy,\\+err_p2p.\n\
\n\
%---CO---\n\
\n\
cond_err_co(s(X,Y,M1), s(Z,Y,M2)) :- match(s(X,Y,M1), R1), match(s(Z,Y,M2), R2), process_rel(R2,R1), !.\n\
cond_err_co(S1, S2) :- \\+match(S1, _), match(S2, _), !.\n\
cond_err_co(_,_) :- !, fail.\n\
\n\
err_co :- event(s(X,Y,M1)), event(s(Z,Y,M2)), M1\\=M2, rel(s(X,Y,M1), s(Z,Y,M2)), cond_err_co(s(X,Y,M1),s(Z,Y,M2)).\n\
\n\
co :- asy,\\+err_co.\n\
\n\
%---MB---\n\
\n\
mb_rel(s(X,Y,M1),s(Z,Y,M2)) :- match(s(X,Y,M1),_), event(s(Z,Y,M2)), M1\\=M2, \\+match(s(Z,Y,M2),_).\n\
mb_rel(s(X,Y,M1),s(Z,Y,M2)) :- match(s(X,Y,M1), R1), match(s(Z,Y,M2), R2), process_rel(R1, R2).\n\
\n\
mb_order(X,Y) :- rel(X,Y).\n\
mb_order(X,Y) :- mb_rel(X,Y).\n\
mb_order(X,Z) :- mb_order(X,Y), mb_order(Y,Z).\n\
err_mb :- mb_order(X,X).\n\
\n\
mb :- \\+err_mb.\n\
\n\
%---1-N---\n\
\n\
onen_rel(s(X,Y,M1),s(X,Z,M2)) :- match(s(X,Y,M1),_), event(s(X,Z,M2)), M1\\=M2, \\+match(s(X,Z,M2),_).\n\
onen_rel(r(X,Y,M1),r(X,Z,M2)) :- match(S1, r(X,Y,M1)), match(S2, r(X,Z,M2)), process_rel(S1, S2).\n\
\n\
onen_order(X,Y) :- rel(X,Y).\n\
onen_order(X,Y) :- onen_rel(X,Y).\n\
onen_order(X,Z) :- onen_order(X,Y), onen_order(Y,Z).\n\
err_onen :- onen_order(X,X).\n\
\n\
onen :- \\+err_onen.\n\
\n\
%---N-N---\n\
\n\
onen_mb_order(X,Y) :- rel(X,Y).\n\
onen_mb_order(X,Y) :- mb_rel(X,Y).\n\
onen_mb_order(X,Y) :- onen_rel(X,Y).\n\
onen_mb_order(X,Z) :- onen_mb_order(X,Y), onen_mb_order(Y,Z).\n\
\n\
nn_rel(X,Y) :- onen_mb_order(X,Y).\n\
\n\
nn_rel(r(X,Y,M1), r(Z,N,M2)) :- match(S1, r(X,Y,M1)), match(S2, r(Z,N,M2)), M1\\=M2, onen_mb_order(S1, S2), \\+onen_mb_order(r(X,Y,M1),r(Z,N,M2)).\n\
\n\
nn_rel(s(X,Y,M1), s(Z,N,M2)) :- match(s(X,Y,M1), R1), match(s(Z,N,M2), R2), M1\\=M2, onen_mb_order(R1, R2), \\+onen_mb_order(s(X,Y,M1),s(Z,N,M2)).\n\
\n\
nn_rel(s(X,Y,M1),s(Z,N,M2)) :- match(s(X,Y,M1),_), event(s(Z,N,M2)), \\+match(s(Z,N,M2),_), \\+onen_mb_order(s(X,Y,M1),s(Z,N,M2)).\n\
nn_rel(r(X,Y,M1),s(Z,N,M2)) :- match(_,r(X,Y,M1)), event(s(Z,N,M2)), \\+match(s(Z,N,M2),_), \\+onen_mb_order(r(X,Y,M1),s(Z,N,M2)).\n\
\n\
nn_rel(X,Z) :- nn_rel(X,Y), nn_rel(Y,Z).\n\
\n\
err_nn :- nn_rel(X,X).\n\
\n\
nn :- \\+err_nn.\n\
\n\
%---RSC---\n\
\n\
crown_rel(s(X,Y,M1), s(Z,N,M2)) :- match(s(Z,N,M2), R2), event(s(X,Y,M1)), M1\\=M2, rel(s(X,Y,M1), R2).\n\
\n\
crown_rel_transitive(X,Y) :- crown_rel(X,Y).\n\
crown_rel_transitive(X,Z) :- crown_rel(X,Y), crown_rel_transitive(Y,Z).\n\
\n\
crown :- crown_rel(X,Y), crown_rel_transitive(Y,X), X\\=Y.\n\
\n\
unmatch(s(X,Y,M)) :- event(s(X,Y,M)), \\+match(s(X,Y,M),_), !.\n\
unmatch(_) :- fail.\n\
\n\
rsc :- \\+crown, \\+unmatch(_).\n";

class DependencyGraph {
	nodes = [];
	events;
	string_prolog = ":- table rel/2, process_rel/2, mb_order/2, onen_order/2, onen_mb_order/2, nn_rel/2, crown_rel_transitive/2.\n";
	session;


	constructor(nodes, draw_edges, events) {
		this.nodes = nodes;
		this.events = events;
		this.string_prolog += this.make_string(nodes, draw_edges, events)+prolog_code;
		
		//console.log(this.string_prolog+prolog_code);
		
	}


	async initalize() {
		console.log("TTT5T\n");	
		
		
		let Module = {
			locateFile: (file) => file
		}
		const options = {
		// Provide options for customization
		};


		let module = await SWIPL(options);

		this.session = module.prolog;

		await this.session.load_string(this.string_prolog);

		let result = this.session.query("nn.").once();
		console.log(result);

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
		
		result[0] = this.session.query("asy.").once().success;

		console.log("asy : " + result[0] + "\n");
		return result;
	}
	async ispp() {
		var result = [false, ""];
		
		result[0] = this.session.query("p2p.").once().success;

		console.log("pp : " + result[0] + "\n");
		return result;
	}
	async isco() {
		var result = [false, ""];
		
		result[0] = this.session.query("co.").once().success;

		console.log("co : " + result[0] + "\n");
		return result;
	}
	async ismb() {
		var result = [false, ""];
		
		result[0] = this.session.query("mb.").once().success;

		console.log("mb : " + result[0] + "\n");
		return result;
	}
	async isonen() {
		var result = [false, ""];
		
		result[0] = this.session.query("onen.").once().success;

		console.log("onen : " + result[0] + "\n");
		return result;
	}
	async isnn() {
		var result = [false, ""];
		
		result[0] = this.session.query("nn.").once().success;

		console.log("nn : " + result[0] + "\n");
		return result;
	}
	async isrsc() {
		var result = [false, ""];
		
		result[0] = this.session.query("rsc.").once().success;

		console.log("rsc : " + result[0] + "\n");
		return result;
	}
}
