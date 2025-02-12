use core::circuit::{
    u384, circuit_add, circuit_sub, circuit_mul, circuit_inverse, EvalCircuitTrait,
    CircuitOutputsTrait, CircuitInputs,
};
use garaga::core::circuit::AddInputResultTrait2;
use garaga::ec_ops::FunctionFelt;
use core::circuit::CircuitElement as CE;
use core::circuit::CircuitInput as CI;
use garaga::definitions::{G1Point, get_GRUMPKIN_modulus, get_BN254_modulus};
use core::option::Option;

#[inline(always)]
pub fn run_GRUMPKIN_HONK_SUMCHECK_SIZE_8_PUB_2_circuit(
    p_public_inputs: Span<u256>,
    p_public_inputs_offset: u384,
    sumcheck_univariates_flat: Span<u256>,
    sumcheck_evaluations: Span<u256>,
    tp_sum_check_u_challenges: Span<u128>,
    tp_gate_challenges: Span<u128>,
    tp_eta_1: u384,
    tp_eta_2: u384,
    tp_eta_3: u384,
    tp_beta: u384,
    tp_gamma: u384,
    tp_base_rlc: u384,
    tp_alphas: Span<u128>,
) -> (u384, u384) {
    // CONSTANT stack
    let in0 = CE::<CI<0>> {}; // 0x1
    let in1 = CE::<CI<1>> {}; // 0x100
    let in2 = CE::<CI<2>> {}; // 0x0
    let in3 = CE::<CI<3>> {}; // 0x30644e72e131a029b85045b68181585d2833e84879b9709143e1f593efffec51
    let in4 = CE::<CI<4>> {}; // 0x2d0
    let in5 = CE::<CI<5>> {}; // 0x30644e72e131a029b85045b68181585d2833e84879b9709143e1f593efffff11
    let in6 = CE::<CI<6>> {}; // 0x90
    let in7 = CE::<CI<7>> {}; // 0x30644e72e131a029b85045b68181585d2833e84879b9709143e1f593efffff71
    let in8 = CE::<CI<8>> {}; // 0xf0
    let in9 = CE::<CI<9>> {}; // 0x30644e72e131a029b85045b68181585d2833e84879b9709143e1f593effffd31
    let in10 = CE::<CI<10>> {}; // 0x13b0
    let in11 = CE::<CI<11>> {}; // 0x2
    let in12 = CE::<CI<12>> {}; // 0x3
    let in13 = CE::<CI<13>> {}; // 0x4
    let in14 = CE::<CI<14>> {}; // 0x5
    let in15 = CE::<CI<15>> {}; // 0x6
    let in16 = CE::<CI<16>> {}; // 0x7
    let in17 = CE::<
        CI<17>,
    > {}; // 0x183227397098d014dc2822db40c0ac2e9419f4243cdcb848a1f0fac9f8000000
    let in18 = CE::<CI<18>> {}; // -0x1 % p
    let in19 = CE::<CI<19>> {}; // -0x2 % p
    let in20 = CE::<CI<20>> {}; // -0x3 % p
    let in21 = CE::<CI<21>> {}; // 0x11
    let in22 = CE::<CI<22>> {}; // 0x9
    let in23 = CE::<CI<23>> {}; // 0x100000000000000000
    let in24 = CE::<CI<24>> {}; // 0x4000
    let in25 = CE::<
        CI<25>,
    > {}; // 0x10dc6e9c006ea38b04b1e03b4bd9490c0d03f98929ca1d7fb56821fd19d3b6e7
    let in26 = CE::<CI<26>> {}; // 0xc28145b6a44df3e0149b3d0a30b3bb599df9756d4dd9b84a86b38cfb45a740b
    let in27 = CE::<CI<27>> {}; // 0x544b8338791518b2c7645a50392798b21f75bb60e3596170067d00141cac15
    let in28 = CE::<
        CI<28>,
    > {}; // 0x222c01175718386f2e2e82eb122789e352e105a3b8fa852613bc534433ee428b

    // INPUT stack
    let (in29, in30, in31) = (CE::<CI<29>> {}, CE::<CI<30>> {}, CE::<CI<31>> {});
    let (in32, in33, in34) = (CE::<CI<32>> {}, CE::<CI<33>> {}, CE::<CI<34>> {});
    let (in35, in36, in37) = (CE::<CI<35>> {}, CE::<CI<36>> {}, CE::<CI<37>> {});
    let (in38, in39, in40) = (CE::<CI<38>> {}, CE::<CI<39>> {}, CE::<CI<40>> {});
    let (in41, in42, in43) = (CE::<CI<41>> {}, CE::<CI<42>> {}, CE::<CI<43>> {});
    let (in44, in45, in46) = (CE::<CI<44>> {}, CE::<CI<45>> {}, CE::<CI<46>> {});
    let (in47, in48, in49) = (CE::<CI<47>> {}, CE::<CI<48>> {}, CE::<CI<49>> {});
    let (in50, in51, in52) = (CE::<CI<50>> {}, CE::<CI<51>> {}, CE::<CI<52>> {});
    let (in53, in54, in55) = (CE::<CI<53>> {}, CE::<CI<54>> {}, CE::<CI<55>> {});
    let (in56, in57, in58) = (CE::<CI<56>> {}, CE::<CI<57>> {}, CE::<CI<58>> {});
    let (in59, in60, in61) = (CE::<CI<59>> {}, CE::<CI<60>> {}, CE::<CI<61>> {});
    let (in62, in63, in64) = (CE::<CI<62>> {}, CE::<CI<63>> {}, CE::<CI<64>> {});
    let (in65, in66, in67) = (CE::<CI<65>> {}, CE::<CI<66>> {}, CE::<CI<67>> {});
    let (in68, in69, in70) = (CE::<CI<68>> {}, CE::<CI<69>> {}, CE::<CI<70>> {});
    let (in71, in72, in73) = (CE::<CI<71>> {}, CE::<CI<72>> {}, CE::<CI<73>> {});
    let (in74, in75, in76) = (CE::<CI<74>> {}, CE::<CI<75>> {}, CE::<CI<76>> {});
    let (in77, in78, in79) = (CE::<CI<77>> {}, CE::<CI<78>> {}, CE::<CI<79>> {});
    let (in80, in81, in82) = (CE::<CI<80>> {}, CE::<CI<81>> {}, CE::<CI<82>> {});
    let (in83, in84, in85) = (CE::<CI<83>> {}, CE::<CI<84>> {}, CE::<CI<85>> {});
    let (in86, in87, in88) = (CE::<CI<86>> {}, CE::<CI<87>> {}, CE::<CI<88>> {});
    let (in89, in90, in91) = (CE::<CI<89>> {}, CE::<CI<90>> {}, CE::<CI<91>> {});
    let (in92, in93, in94) = (CE::<CI<92>> {}, CE::<CI<93>> {}, CE::<CI<94>> {});
    let (in95, in96, in97) = (CE::<CI<95>> {}, CE::<CI<96>> {}, CE::<CI<97>> {});
    let (in98, in99, in100) = (CE::<CI<98>> {}, CE::<CI<99>> {}, CE::<CI<100>> {});
    let (in101, in102, in103) = (CE::<CI<101>> {}, CE::<CI<102>> {}, CE::<CI<103>> {});
    let (in104, in105, in106) = (CE::<CI<104>> {}, CE::<CI<105>> {}, CE::<CI<106>> {});
    let (in107, in108, in109) = (CE::<CI<107>> {}, CE::<CI<108>> {}, CE::<CI<109>> {});
    let (in110, in111, in112) = (CE::<CI<110>> {}, CE::<CI<111>> {}, CE::<CI<112>> {});
    let (in113, in114, in115) = (CE::<CI<113>> {}, CE::<CI<114>> {}, CE::<CI<115>> {});
    let (in116, in117, in118) = (CE::<CI<116>> {}, CE::<CI<117>> {}, CE::<CI<118>> {});
    let (in119, in120, in121) = (CE::<CI<119>> {}, CE::<CI<120>> {}, CE::<CI<121>> {});
    let (in122, in123, in124) = (CE::<CI<122>> {}, CE::<CI<123>> {}, CE::<CI<124>> {});
    let (in125, in126, in127) = (CE::<CI<125>> {}, CE::<CI<126>> {}, CE::<CI<127>> {});
    let (in128, in129, in130) = (CE::<CI<128>> {}, CE::<CI<129>> {}, CE::<CI<130>> {});
    let (in131, in132, in133) = (CE::<CI<131>> {}, CE::<CI<132>> {}, CE::<CI<133>> {});
    let (in134, in135, in136) = (CE::<CI<134>> {}, CE::<CI<135>> {}, CE::<CI<136>> {});
    let (in137, in138, in139) = (CE::<CI<137>> {}, CE::<CI<138>> {}, CE::<CI<139>> {});
    let (in140, in141, in142) = (CE::<CI<140>> {}, CE::<CI<141>> {}, CE::<CI<142>> {});
    let (in143, in144, in145) = (CE::<CI<143>> {}, CE::<CI<144>> {}, CE::<CI<145>> {});
    let (in146, in147, in148) = (CE::<CI<146>> {}, CE::<CI<147>> {}, CE::<CI<148>> {});
    let (in149, in150, in151) = (CE::<CI<149>> {}, CE::<CI<150>> {}, CE::<CI<151>> {});
    let (in152, in153, in154) = (CE::<CI<152>> {}, CE::<CI<153>> {}, CE::<CI<154>> {});
    let (in155, in156, in157) = (CE::<CI<155>> {}, CE::<CI<156>> {}, CE::<CI<157>> {});
    let (in158, in159, in160) = (CE::<CI<158>> {}, CE::<CI<159>> {}, CE::<CI<160>> {});
    let (in161, in162, in163) = (CE::<CI<161>> {}, CE::<CI<162>> {}, CE::<CI<163>> {});
    let (in164, in165, in166) = (CE::<CI<164>> {}, CE::<CI<165>> {}, CE::<CI<166>> {});
    let (in167, in168, in169) = (CE::<CI<167>> {}, CE::<CI<168>> {}, CE::<CI<169>> {});
    let (in170, in171, in172) = (CE::<CI<170>> {}, CE::<CI<171>> {}, CE::<CI<172>> {});
    let (in173, in174, in175) = (CE::<CI<173>> {}, CE::<CI<174>> {}, CE::<CI<175>> {});
    let (in176, in177, in178) = (CE::<CI<176>> {}, CE::<CI<177>> {}, CE::<CI<178>> {});
    let (in179, in180, in181) = (CE::<CI<179>> {}, CE::<CI<180>> {}, CE::<CI<181>> {});
    let in182 = CE::<CI<182>> {};
    let t0 = circuit_add(in1, in31);
    let t1 = circuit_mul(in155, t0);
    let t2 = circuit_add(in156, t1);
    let t3 = circuit_add(in31, in0);
    let t4 = circuit_mul(in155, t3);
    let t5 = circuit_sub(in156, t4);
    let t6 = circuit_add(t2, in29);
    let t7 = circuit_mul(in0, t6);
    let t8 = circuit_add(t5, in29);
    let t9 = circuit_mul(in0, t8);
    let t10 = circuit_add(t2, in155);
    let t11 = circuit_sub(t5, in155);
    let t12 = circuit_add(t10, in30);
    let t13 = circuit_mul(t7, t12);
    let t14 = circuit_add(t11, in30);
    let t15 = circuit_mul(t9, t14);
    let t16 = circuit_inverse(t15);
    let t17 = circuit_mul(t13, t16);
    let t18 = circuit_add(in32, in33);
    let t19 = circuit_sub(t18, in2);
    let t20 = circuit_mul(t19, in157);
    let t21 = circuit_add(in2, t20);
    let t22 = circuit_mul(in157, in157);
    let t23 = circuit_sub(in136, in2);
    let t24 = circuit_mul(in0, t23);
    let t25 = circuit_sub(in136, in2);
    let t26 = circuit_mul(in3, t25);
    let t27 = circuit_inverse(t26);
    let t28 = circuit_mul(in32, t27);
    let t29 = circuit_add(in2, t28);
    let t30 = circuit_sub(in136, in0);
    let t31 = circuit_mul(t24, t30);
    let t32 = circuit_sub(in136, in0);
    let t33 = circuit_mul(in4, t32);
    let t34 = circuit_inverse(t33);
    let t35 = circuit_mul(in33, t34);
    let t36 = circuit_add(t29, t35);
    let t37 = circuit_sub(in136, in11);
    let t38 = circuit_mul(t31, t37);
    let t39 = circuit_sub(in136, in11);
    let t40 = circuit_mul(in5, t39);
    let t41 = circuit_inverse(t40);
    let t42 = circuit_mul(in34, t41);
    let t43 = circuit_add(t36, t42);
    let t44 = circuit_sub(in136, in12);
    let t45 = circuit_mul(t38, t44);
    let t46 = circuit_sub(in136, in12);
    let t47 = circuit_mul(in6, t46);
    let t48 = circuit_inverse(t47);
    let t49 = circuit_mul(in35, t48);
    let t50 = circuit_add(t43, t49);
    let t51 = circuit_sub(in136, in13);
    let t52 = circuit_mul(t45, t51);
    let t53 = circuit_sub(in136, in13);
    let t54 = circuit_mul(in7, t53);
    let t55 = circuit_inverse(t54);
    let t56 = circuit_mul(in36, t55);
    let t57 = circuit_add(t50, t56);
    let t58 = circuit_sub(in136, in14);
    let t59 = circuit_mul(t52, t58);
    let t60 = circuit_sub(in136, in14);
    let t61 = circuit_mul(in8, t60);
    let t62 = circuit_inverse(t61);
    let t63 = circuit_mul(in37, t62);
    let t64 = circuit_add(t57, t63);
    let t65 = circuit_sub(in136, in15);
    let t66 = circuit_mul(t59, t65);
    let t67 = circuit_sub(in136, in15);
    let t68 = circuit_mul(in9, t67);
    let t69 = circuit_inverse(t68);
    let t70 = circuit_mul(in38, t69);
    let t71 = circuit_add(t64, t70);
    let t72 = circuit_sub(in136, in16);
    let t73 = circuit_mul(t66, t72);
    let t74 = circuit_sub(in136, in16);
    let t75 = circuit_mul(in10, t74);
    let t76 = circuit_inverse(t75);
    let t77 = circuit_mul(in39, t76);
    let t78 = circuit_add(t71, t77);
    let t79 = circuit_mul(t78, t73);
    let t80 = circuit_sub(in144, in0);
    let t81 = circuit_mul(in136, t80);
    let t82 = circuit_add(in0, t81);
    let t83 = circuit_mul(in0, t82);
    let t84 = circuit_add(in40, in41);
    let t85 = circuit_sub(t84, t79);
    let t86 = circuit_mul(t85, t22);
    let t87 = circuit_add(t21, t86);
    let t88 = circuit_mul(t22, in157);
    let t89 = circuit_sub(in137, in2);
    let t90 = circuit_mul(in0, t89);
    let t91 = circuit_sub(in137, in2);
    let t92 = circuit_mul(in3, t91);
    let t93 = circuit_inverse(t92);
    let t94 = circuit_mul(in40, t93);
    let t95 = circuit_add(in2, t94);
    let t96 = circuit_sub(in137, in0);
    let t97 = circuit_mul(t90, t96);
    let t98 = circuit_sub(in137, in0);
    let t99 = circuit_mul(in4, t98);
    let t100 = circuit_inverse(t99);
    let t101 = circuit_mul(in41, t100);
    let t102 = circuit_add(t95, t101);
    let t103 = circuit_sub(in137, in11);
    let t104 = circuit_mul(t97, t103);
    let t105 = circuit_sub(in137, in11);
    let t106 = circuit_mul(in5, t105);
    let t107 = circuit_inverse(t106);
    let t108 = circuit_mul(in42, t107);
    let t109 = circuit_add(t102, t108);
    let t110 = circuit_sub(in137, in12);
    let t111 = circuit_mul(t104, t110);
    let t112 = circuit_sub(in137, in12);
    let t113 = circuit_mul(in6, t112);
    let t114 = circuit_inverse(t113);
    let t115 = circuit_mul(in43, t114);
    let t116 = circuit_add(t109, t115);
    let t117 = circuit_sub(in137, in13);
    let t118 = circuit_mul(t111, t117);
    let t119 = circuit_sub(in137, in13);
    let t120 = circuit_mul(in7, t119);
    let t121 = circuit_inverse(t120);
    let t122 = circuit_mul(in44, t121);
    let t123 = circuit_add(t116, t122);
    let t124 = circuit_sub(in137, in14);
    let t125 = circuit_mul(t118, t124);
    let t126 = circuit_sub(in137, in14);
    let t127 = circuit_mul(in8, t126);
    let t128 = circuit_inverse(t127);
    let t129 = circuit_mul(in45, t128);
    let t130 = circuit_add(t123, t129);
    let t131 = circuit_sub(in137, in15);
    let t132 = circuit_mul(t125, t131);
    let t133 = circuit_sub(in137, in15);
    let t134 = circuit_mul(in9, t133);
    let t135 = circuit_inverse(t134);
    let t136 = circuit_mul(in46, t135);
    let t137 = circuit_add(t130, t136);
    let t138 = circuit_sub(in137, in16);
    let t139 = circuit_mul(t132, t138);
    let t140 = circuit_sub(in137, in16);
    let t141 = circuit_mul(in10, t140);
    let t142 = circuit_inverse(t141);
    let t143 = circuit_mul(in47, t142);
    let t144 = circuit_add(t137, t143);
    let t145 = circuit_mul(t144, t139);
    let t146 = circuit_sub(in145, in0);
    let t147 = circuit_mul(in137, t146);
    let t148 = circuit_add(in0, t147);
    let t149 = circuit_mul(t83, t148);
    let t150 = circuit_add(in48, in49);
    let t151 = circuit_sub(t150, t145);
    let t152 = circuit_mul(t151, t88);
    let t153 = circuit_add(t87, t152);
    let t154 = circuit_mul(t88, in157);
    let t155 = circuit_sub(in138, in2);
    let t156 = circuit_mul(in0, t155);
    let t157 = circuit_sub(in138, in2);
    let t158 = circuit_mul(in3, t157);
    let t159 = circuit_inverse(t158);
    let t160 = circuit_mul(in48, t159);
    let t161 = circuit_add(in2, t160);
    let t162 = circuit_sub(in138, in0);
    let t163 = circuit_mul(t156, t162);
    let t164 = circuit_sub(in138, in0);
    let t165 = circuit_mul(in4, t164);
    let t166 = circuit_inverse(t165);
    let t167 = circuit_mul(in49, t166);
    let t168 = circuit_add(t161, t167);
    let t169 = circuit_sub(in138, in11);
    let t170 = circuit_mul(t163, t169);
    let t171 = circuit_sub(in138, in11);
    let t172 = circuit_mul(in5, t171);
    let t173 = circuit_inverse(t172);
    let t174 = circuit_mul(in50, t173);
    let t175 = circuit_add(t168, t174);
    let t176 = circuit_sub(in138, in12);
    let t177 = circuit_mul(t170, t176);
    let t178 = circuit_sub(in138, in12);
    let t179 = circuit_mul(in6, t178);
    let t180 = circuit_inverse(t179);
    let t181 = circuit_mul(in51, t180);
    let t182 = circuit_add(t175, t181);
    let t183 = circuit_sub(in138, in13);
    let t184 = circuit_mul(t177, t183);
    let t185 = circuit_sub(in138, in13);
    let t186 = circuit_mul(in7, t185);
    let t187 = circuit_inverse(t186);
    let t188 = circuit_mul(in52, t187);
    let t189 = circuit_add(t182, t188);
    let t190 = circuit_sub(in138, in14);
    let t191 = circuit_mul(t184, t190);
    let t192 = circuit_sub(in138, in14);
    let t193 = circuit_mul(in8, t192);
    let t194 = circuit_inverse(t193);
    let t195 = circuit_mul(in53, t194);
    let t196 = circuit_add(t189, t195);
    let t197 = circuit_sub(in138, in15);
    let t198 = circuit_mul(t191, t197);
    let t199 = circuit_sub(in138, in15);
    let t200 = circuit_mul(in9, t199);
    let t201 = circuit_inverse(t200);
    let t202 = circuit_mul(in54, t201);
    let t203 = circuit_add(t196, t202);
    let t204 = circuit_sub(in138, in16);
    let t205 = circuit_mul(t198, t204);
    let t206 = circuit_sub(in138, in16);
    let t207 = circuit_mul(in10, t206);
    let t208 = circuit_inverse(t207);
    let t209 = circuit_mul(in55, t208);
    let t210 = circuit_add(t203, t209);
    let t211 = circuit_mul(t210, t205);
    let t212 = circuit_sub(in146, in0);
    let t213 = circuit_mul(in138, t212);
    let t214 = circuit_add(in0, t213);
    let t215 = circuit_mul(t149, t214);
    let t216 = circuit_add(in56, in57);
    let t217 = circuit_sub(t216, t211);
    let t218 = circuit_mul(t217, t154);
    let t219 = circuit_add(t153, t218);
    let t220 = circuit_mul(t154, in157);
    let t221 = circuit_sub(in139, in2);
    let t222 = circuit_mul(in0, t221);
    let t223 = circuit_sub(in139, in2);
    let t224 = circuit_mul(in3, t223);
    let t225 = circuit_inverse(t224);
    let t226 = circuit_mul(in56, t225);
    let t227 = circuit_add(in2, t226);
    let t228 = circuit_sub(in139, in0);
    let t229 = circuit_mul(t222, t228);
    let t230 = circuit_sub(in139, in0);
    let t231 = circuit_mul(in4, t230);
    let t232 = circuit_inverse(t231);
    let t233 = circuit_mul(in57, t232);
    let t234 = circuit_add(t227, t233);
    let t235 = circuit_sub(in139, in11);
    let t236 = circuit_mul(t229, t235);
    let t237 = circuit_sub(in139, in11);
    let t238 = circuit_mul(in5, t237);
    let t239 = circuit_inverse(t238);
    let t240 = circuit_mul(in58, t239);
    let t241 = circuit_add(t234, t240);
    let t242 = circuit_sub(in139, in12);
    let t243 = circuit_mul(t236, t242);
    let t244 = circuit_sub(in139, in12);
    let t245 = circuit_mul(in6, t244);
    let t246 = circuit_inverse(t245);
    let t247 = circuit_mul(in59, t246);
    let t248 = circuit_add(t241, t247);
    let t249 = circuit_sub(in139, in13);
    let t250 = circuit_mul(t243, t249);
    let t251 = circuit_sub(in139, in13);
    let t252 = circuit_mul(in7, t251);
    let t253 = circuit_inverse(t252);
    let t254 = circuit_mul(in60, t253);
    let t255 = circuit_add(t248, t254);
    let t256 = circuit_sub(in139, in14);
    let t257 = circuit_mul(t250, t256);
    let t258 = circuit_sub(in139, in14);
    let t259 = circuit_mul(in8, t258);
    let t260 = circuit_inverse(t259);
    let t261 = circuit_mul(in61, t260);
    let t262 = circuit_add(t255, t261);
    let t263 = circuit_sub(in139, in15);
    let t264 = circuit_mul(t257, t263);
    let t265 = circuit_sub(in139, in15);
    let t266 = circuit_mul(in9, t265);
    let t267 = circuit_inverse(t266);
    let t268 = circuit_mul(in62, t267);
    let t269 = circuit_add(t262, t268);
    let t270 = circuit_sub(in139, in16);
    let t271 = circuit_mul(t264, t270);
    let t272 = circuit_sub(in139, in16);
    let t273 = circuit_mul(in10, t272);
    let t274 = circuit_inverse(t273);
    let t275 = circuit_mul(in63, t274);
    let t276 = circuit_add(t269, t275);
    let t277 = circuit_mul(t276, t271);
    let t278 = circuit_sub(in147, in0);
    let t279 = circuit_mul(in139, t278);
    let t280 = circuit_add(in0, t279);
    let t281 = circuit_mul(t215, t280);
    let t282 = circuit_add(in64, in65);
    let t283 = circuit_sub(t282, t277);
    let t284 = circuit_mul(t283, t220);
    let t285 = circuit_add(t219, t284);
    let t286 = circuit_mul(t220, in157);
    let t287 = circuit_sub(in140, in2);
    let t288 = circuit_mul(in0, t287);
    let t289 = circuit_sub(in140, in2);
    let t290 = circuit_mul(in3, t289);
    let t291 = circuit_inverse(t290);
    let t292 = circuit_mul(in64, t291);
    let t293 = circuit_add(in2, t292);
    let t294 = circuit_sub(in140, in0);
    let t295 = circuit_mul(t288, t294);
    let t296 = circuit_sub(in140, in0);
    let t297 = circuit_mul(in4, t296);
    let t298 = circuit_inverse(t297);
    let t299 = circuit_mul(in65, t298);
    let t300 = circuit_add(t293, t299);
    let t301 = circuit_sub(in140, in11);
    let t302 = circuit_mul(t295, t301);
    let t303 = circuit_sub(in140, in11);
    let t304 = circuit_mul(in5, t303);
    let t305 = circuit_inverse(t304);
    let t306 = circuit_mul(in66, t305);
    let t307 = circuit_add(t300, t306);
    let t308 = circuit_sub(in140, in12);
    let t309 = circuit_mul(t302, t308);
    let t310 = circuit_sub(in140, in12);
    let t311 = circuit_mul(in6, t310);
    let t312 = circuit_inverse(t311);
    let t313 = circuit_mul(in67, t312);
    let t314 = circuit_add(t307, t313);
    let t315 = circuit_sub(in140, in13);
    let t316 = circuit_mul(t309, t315);
    let t317 = circuit_sub(in140, in13);
    let t318 = circuit_mul(in7, t317);
    let t319 = circuit_inverse(t318);
    let t320 = circuit_mul(in68, t319);
    let t321 = circuit_add(t314, t320);
    let t322 = circuit_sub(in140, in14);
    let t323 = circuit_mul(t316, t322);
    let t324 = circuit_sub(in140, in14);
    let t325 = circuit_mul(in8, t324);
    let t326 = circuit_inverse(t325);
    let t327 = circuit_mul(in69, t326);
    let t328 = circuit_add(t321, t327);
    let t329 = circuit_sub(in140, in15);
    let t330 = circuit_mul(t323, t329);
    let t331 = circuit_sub(in140, in15);
    let t332 = circuit_mul(in9, t331);
    let t333 = circuit_inverse(t332);
    let t334 = circuit_mul(in70, t333);
    let t335 = circuit_add(t328, t334);
    let t336 = circuit_sub(in140, in16);
    let t337 = circuit_mul(t330, t336);
    let t338 = circuit_sub(in140, in16);
    let t339 = circuit_mul(in10, t338);
    let t340 = circuit_inverse(t339);
    let t341 = circuit_mul(in71, t340);
    let t342 = circuit_add(t335, t341);
    let t343 = circuit_mul(t342, t337);
    let t344 = circuit_sub(in148, in0);
    let t345 = circuit_mul(in140, t344);
    let t346 = circuit_add(in0, t345);
    let t347 = circuit_mul(t281, t346);
    let t348 = circuit_add(in72, in73);
    let t349 = circuit_sub(t348, t343);
    let t350 = circuit_mul(t349, t286);
    let t351 = circuit_add(t285, t350);
    let t352 = circuit_mul(t286, in157);
    let t353 = circuit_sub(in141, in2);
    let t354 = circuit_mul(in0, t353);
    let t355 = circuit_sub(in141, in2);
    let t356 = circuit_mul(in3, t355);
    let t357 = circuit_inverse(t356);
    let t358 = circuit_mul(in72, t357);
    let t359 = circuit_add(in2, t358);
    let t360 = circuit_sub(in141, in0);
    let t361 = circuit_mul(t354, t360);
    let t362 = circuit_sub(in141, in0);
    let t363 = circuit_mul(in4, t362);
    let t364 = circuit_inverse(t363);
    let t365 = circuit_mul(in73, t364);
    let t366 = circuit_add(t359, t365);
    let t367 = circuit_sub(in141, in11);
    let t368 = circuit_mul(t361, t367);
    let t369 = circuit_sub(in141, in11);
    let t370 = circuit_mul(in5, t369);
    let t371 = circuit_inverse(t370);
    let t372 = circuit_mul(in74, t371);
    let t373 = circuit_add(t366, t372);
    let t374 = circuit_sub(in141, in12);
    let t375 = circuit_mul(t368, t374);
    let t376 = circuit_sub(in141, in12);
    let t377 = circuit_mul(in6, t376);
    let t378 = circuit_inverse(t377);
    let t379 = circuit_mul(in75, t378);
    let t380 = circuit_add(t373, t379);
    let t381 = circuit_sub(in141, in13);
    let t382 = circuit_mul(t375, t381);
    let t383 = circuit_sub(in141, in13);
    let t384 = circuit_mul(in7, t383);
    let t385 = circuit_inverse(t384);
    let t386 = circuit_mul(in76, t385);
    let t387 = circuit_add(t380, t386);
    let t388 = circuit_sub(in141, in14);
    let t389 = circuit_mul(t382, t388);
    let t390 = circuit_sub(in141, in14);
    let t391 = circuit_mul(in8, t390);
    let t392 = circuit_inverse(t391);
    let t393 = circuit_mul(in77, t392);
    let t394 = circuit_add(t387, t393);
    let t395 = circuit_sub(in141, in15);
    let t396 = circuit_mul(t389, t395);
    let t397 = circuit_sub(in141, in15);
    let t398 = circuit_mul(in9, t397);
    let t399 = circuit_inverse(t398);
    let t400 = circuit_mul(in78, t399);
    let t401 = circuit_add(t394, t400);
    let t402 = circuit_sub(in141, in16);
    let t403 = circuit_mul(t396, t402);
    let t404 = circuit_sub(in141, in16);
    let t405 = circuit_mul(in10, t404);
    let t406 = circuit_inverse(t405);
    let t407 = circuit_mul(in79, t406);
    let t408 = circuit_add(t401, t407);
    let t409 = circuit_mul(t408, t403);
    let t410 = circuit_sub(in149, in0);
    let t411 = circuit_mul(in141, t410);
    let t412 = circuit_add(in0, t411);
    let t413 = circuit_mul(t347, t412);
    let t414 = circuit_add(in80, in81);
    let t415 = circuit_sub(t414, t409);
    let t416 = circuit_mul(t415, t352);
    let t417 = circuit_add(t351, t416);
    let t418 = circuit_mul(t352, in157);
    let t419 = circuit_sub(in142, in2);
    let t420 = circuit_mul(in0, t419);
    let t421 = circuit_sub(in142, in2);
    let t422 = circuit_mul(in3, t421);
    let t423 = circuit_inverse(t422);
    let t424 = circuit_mul(in80, t423);
    let t425 = circuit_add(in2, t424);
    let t426 = circuit_sub(in142, in0);
    let t427 = circuit_mul(t420, t426);
    let t428 = circuit_sub(in142, in0);
    let t429 = circuit_mul(in4, t428);
    let t430 = circuit_inverse(t429);
    let t431 = circuit_mul(in81, t430);
    let t432 = circuit_add(t425, t431);
    let t433 = circuit_sub(in142, in11);
    let t434 = circuit_mul(t427, t433);
    let t435 = circuit_sub(in142, in11);
    let t436 = circuit_mul(in5, t435);
    let t437 = circuit_inverse(t436);
    let t438 = circuit_mul(in82, t437);
    let t439 = circuit_add(t432, t438);
    let t440 = circuit_sub(in142, in12);
    let t441 = circuit_mul(t434, t440);
    let t442 = circuit_sub(in142, in12);
    let t443 = circuit_mul(in6, t442);
    let t444 = circuit_inverse(t443);
    let t445 = circuit_mul(in83, t444);
    let t446 = circuit_add(t439, t445);
    let t447 = circuit_sub(in142, in13);
    let t448 = circuit_mul(t441, t447);
    let t449 = circuit_sub(in142, in13);
    let t450 = circuit_mul(in7, t449);
    let t451 = circuit_inverse(t450);
    let t452 = circuit_mul(in84, t451);
    let t453 = circuit_add(t446, t452);
    let t454 = circuit_sub(in142, in14);
    let t455 = circuit_mul(t448, t454);
    let t456 = circuit_sub(in142, in14);
    let t457 = circuit_mul(in8, t456);
    let t458 = circuit_inverse(t457);
    let t459 = circuit_mul(in85, t458);
    let t460 = circuit_add(t453, t459);
    let t461 = circuit_sub(in142, in15);
    let t462 = circuit_mul(t455, t461);
    let t463 = circuit_sub(in142, in15);
    let t464 = circuit_mul(in9, t463);
    let t465 = circuit_inverse(t464);
    let t466 = circuit_mul(in86, t465);
    let t467 = circuit_add(t460, t466);
    let t468 = circuit_sub(in142, in16);
    let t469 = circuit_mul(t462, t468);
    let t470 = circuit_sub(in142, in16);
    let t471 = circuit_mul(in10, t470);
    let t472 = circuit_inverse(t471);
    let t473 = circuit_mul(in87, t472);
    let t474 = circuit_add(t467, t473);
    let t475 = circuit_mul(t474, t469);
    let t476 = circuit_sub(in150, in0);
    let t477 = circuit_mul(in142, t476);
    let t478 = circuit_add(in0, t477);
    let t479 = circuit_mul(t413, t478);
    let t480 = circuit_add(in88, in89);
    let t481 = circuit_sub(t480, t475);
    let t482 = circuit_mul(t481, t418);
    let t483 = circuit_add(t417, t482);
    let t484 = circuit_sub(in143, in2);
    let t485 = circuit_mul(in0, t484);
    let t486 = circuit_sub(in143, in2);
    let t487 = circuit_mul(in3, t486);
    let t488 = circuit_inverse(t487);
    let t489 = circuit_mul(in88, t488);
    let t490 = circuit_add(in2, t489);
    let t491 = circuit_sub(in143, in0);
    let t492 = circuit_mul(t485, t491);
    let t493 = circuit_sub(in143, in0);
    let t494 = circuit_mul(in4, t493);
    let t495 = circuit_inverse(t494);
    let t496 = circuit_mul(in89, t495);
    let t497 = circuit_add(t490, t496);
    let t498 = circuit_sub(in143, in11);
    let t499 = circuit_mul(t492, t498);
    let t500 = circuit_sub(in143, in11);
    let t501 = circuit_mul(in5, t500);
    let t502 = circuit_inverse(t501);
    let t503 = circuit_mul(in90, t502);
    let t504 = circuit_add(t497, t503);
    let t505 = circuit_sub(in143, in12);
    let t506 = circuit_mul(t499, t505);
    let t507 = circuit_sub(in143, in12);
    let t508 = circuit_mul(in6, t507);
    let t509 = circuit_inverse(t508);
    let t510 = circuit_mul(in91, t509);
    let t511 = circuit_add(t504, t510);
    let t512 = circuit_sub(in143, in13);
    let t513 = circuit_mul(t506, t512);
    let t514 = circuit_sub(in143, in13);
    let t515 = circuit_mul(in7, t514);
    let t516 = circuit_inverse(t515);
    let t517 = circuit_mul(in92, t516);
    let t518 = circuit_add(t511, t517);
    let t519 = circuit_sub(in143, in14);
    let t520 = circuit_mul(t513, t519);
    let t521 = circuit_sub(in143, in14);
    let t522 = circuit_mul(in8, t521);
    let t523 = circuit_inverse(t522);
    let t524 = circuit_mul(in93, t523);
    let t525 = circuit_add(t518, t524);
    let t526 = circuit_sub(in143, in15);
    let t527 = circuit_mul(t520, t526);
    let t528 = circuit_sub(in143, in15);
    let t529 = circuit_mul(in9, t528);
    let t530 = circuit_inverse(t529);
    let t531 = circuit_mul(in94, t530);
    let t532 = circuit_add(t525, t531);
    let t533 = circuit_sub(in143, in16);
    let t534 = circuit_mul(t527, t533);
    let t535 = circuit_sub(in143, in16);
    let t536 = circuit_mul(in10, t535);
    let t537 = circuit_inverse(t536);
    let t538 = circuit_mul(in95, t537);
    let t539 = circuit_add(t532, t538);
    let t540 = circuit_mul(t539, t534);
    let t541 = circuit_sub(in151, in0);
    let t542 = circuit_mul(in143, t541);
    let t543 = circuit_add(in0, t542);
    let t544 = circuit_mul(t479, t543);
    let t545 = circuit_sub(in102, in12);
    let t546 = circuit_mul(t545, in96);
    let t547 = circuit_mul(t546, in124);
    let t548 = circuit_mul(t547, in123);
    let t549 = circuit_mul(t548, in17);
    let t550 = circuit_mul(in98, in123);
    let t551 = circuit_mul(in99, in124);
    let t552 = circuit_mul(in100, in125);
    let t553 = circuit_mul(in101, in126);
    let t554 = circuit_add(t549, t550);
    let t555 = circuit_add(t554, t551);
    let t556 = circuit_add(t555, t552);
    let t557 = circuit_add(t556, t553);
    let t558 = circuit_add(t557, in97);
    let t559 = circuit_sub(in102, in0);
    let t560 = circuit_mul(t559, in134);
    let t561 = circuit_add(t558, t560);
    let t562 = circuit_mul(t561, in102);
    let t563 = circuit_mul(t562, t544);
    let t564 = circuit_add(in123, in126);
    let t565 = circuit_add(t564, in96);
    let t566 = circuit_sub(t565, in131);
    let t567 = circuit_sub(in102, in11);
    let t568 = circuit_mul(t566, t567);
    let t569 = circuit_sub(in102, in0);
    let t570 = circuit_mul(t568, t569);
    let t571 = circuit_mul(t570, in102);
    let t572 = circuit_mul(t571, t544);
    let t573 = circuit_mul(in113, in155);
    let t574 = circuit_add(in123, t573);
    let t575 = circuit_add(t574, in156);
    let t576 = circuit_mul(in114, in155);
    let t577 = circuit_add(in124, t576);
    let t578 = circuit_add(t577, in156);
    let t579 = circuit_mul(t575, t578);
    let t580 = circuit_mul(in115, in155);
    let t581 = circuit_add(in125, t580);
    let t582 = circuit_add(t581, in156);
    let t583 = circuit_mul(t579, t582);
    let t584 = circuit_mul(in116, in155);
    let t585 = circuit_add(in126, t584);
    let t586 = circuit_add(t585, in156);
    let t587 = circuit_mul(t583, t586);
    let t588 = circuit_mul(in109, in155);
    let t589 = circuit_add(in123, t588);
    let t590 = circuit_add(t589, in156);
    let t591 = circuit_mul(in110, in155);
    let t592 = circuit_add(in124, t591);
    let t593 = circuit_add(t592, in156);
    let t594 = circuit_mul(t590, t593);
    let t595 = circuit_mul(in111, in155);
    let t596 = circuit_add(in125, t595);
    let t597 = circuit_add(t596, in156);
    let t598 = circuit_mul(t594, t597);
    let t599 = circuit_mul(in112, in155);
    let t600 = circuit_add(in126, t599);
    let t601 = circuit_add(t600, in156);
    let t602 = circuit_mul(t598, t601);
    let t603 = circuit_add(in127, in121);
    let t604 = circuit_mul(t587, t603);
    let t605 = circuit_mul(in122, t17);
    let t606 = circuit_add(in135, t605);
    let t607 = circuit_mul(t602, t606);
    let t608 = circuit_sub(t604, t607);
    let t609 = circuit_mul(t608, t544);
    let t610 = circuit_mul(in122, in135);
    let t611 = circuit_mul(t610, t544);
    let t612 = circuit_mul(in118, in152);
    let t613 = circuit_mul(in119, in153);
    let t614 = circuit_mul(in120, in154);
    let t615 = circuit_add(in117, in156);
    let t616 = circuit_add(t615, t612);
    let t617 = circuit_add(t616, t613);
    let t618 = circuit_add(t617, t614);
    let t619 = circuit_mul(in99, in131);
    let t620 = circuit_add(in123, in156);
    let t621 = circuit_add(t620, t619);
    let t622 = circuit_mul(in96, in132);
    let t623 = circuit_add(in124, t622);
    let t624 = circuit_mul(in97, in133);
    let t625 = circuit_add(in125, t624);
    let t626 = circuit_mul(t623, in152);
    let t627 = circuit_mul(t625, in153);
    let t628 = circuit_mul(in100, in154);
    let t629 = circuit_add(t621, t626);
    let t630 = circuit_add(t629, t627);
    let t631 = circuit_add(t630, t628);
    let t632 = circuit_mul(in128, t618);
    let t633 = circuit_mul(in128, t631);
    let t634 = circuit_add(in130, in106);
    let t635 = circuit_mul(in130, in106);
    let t636 = circuit_sub(t634, t635);
    let t637 = circuit_mul(t631, t618);
    let t638 = circuit_mul(t637, in128);
    let t639 = circuit_sub(t638, t636);
    let t640 = circuit_mul(t639, t544);
    let t641 = circuit_mul(in106, t632);
    let t642 = circuit_mul(in129, t633);
    let t643 = circuit_sub(t641, t642);
    let t644 = circuit_sub(in124, in123);
    let t645 = circuit_sub(in125, in124);
    let t646 = circuit_sub(in126, in125);
    let t647 = circuit_sub(in131, in126);
    let t648 = circuit_add(t644, in18);
    let t649 = circuit_add(t644, in19);
    let t650 = circuit_add(t644, in20);
    let t651 = circuit_mul(t644, t648);
    let t652 = circuit_mul(t651, t649);
    let t653 = circuit_mul(t652, t650);
    let t654 = circuit_mul(t653, in103);
    let t655 = circuit_mul(t654, t544);
    let t656 = circuit_add(t645, in18);
    let t657 = circuit_add(t645, in19);
    let t658 = circuit_add(t645, in20);
    let t659 = circuit_mul(t645, t656);
    let t660 = circuit_mul(t659, t657);
    let t661 = circuit_mul(t660, t658);
    let t662 = circuit_mul(t661, in103);
    let t663 = circuit_mul(t662, t544);
    let t664 = circuit_add(t646, in18);
    let t665 = circuit_add(t646, in19);
    let t666 = circuit_add(t646, in20);
    let t667 = circuit_mul(t646, t664);
    let t668 = circuit_mul(t667, t665);
    let t669 = circuit_mul(t668, t666);
    let t670 = circuit_mul(t669, in103);
    let t671 = circuit_mul(t670, t544);
    let t672 = circuit_add(t647, in18);
    let t673 = circuit_add(t647, in19);
    let t674 = circuit_add(t647, in20);
    let t675 = circuit_mul(t647, t672);
    let t676 = circuit_mul(t675, t673);
    let t677 = circuit_mul(t676, t674);
    let t678 = circuit_mul(t677, in103);
    let t679 = circuit_mul(t678, t544);
    let t680 = circuit_sub(in131, in124);
    let t681 = circuit_mul(in125, in125);
    let t682 = circuit_mul(in134, in134);
    let t683 = circuit_mul(in125, in134);
    let t684 = circuit_mul(t683, in98);
    let t685 = circuit_add(in132, in131);
    let t686 = circuit_add(t685, in124);
    let t687 = circuit_mul(t686, t680);
    let t688 = circuit_mul(t687, t680);
    let t689 = circuit_sub(t688, t682);
    let t690 = circuit_sub(t689, t681);
    let t691 = circuit_add(t690, t684);
    let t692 = circuit_add(t691, t684);
    let t693 = circuit_sub(in0, in96);
    let t694 = circuit_mul(t692, t544);
    let t695 = circuit_mul(t694, in104);
    let t696 = circuit_mul(t695, t693);
    let t697 = circuit_add(in125, in133);
    let t698 = circuit_mul(in134, in98);
    let t699 = circuit_sub(t698, in125);
    let t700 = circuit_mul(t697, t680);
    let t701 = circuit_sub(in132, in124);
    let t702 = circuit_mul(t701, t699);
    let t703 = circuit_add(t700, t702);
    let t704 = circuit_mul(t703, t544);
    let t705 = circuit_mul(t704, in104);
    let t706 = circuit_mul(t705, t693);
    let t707 = circuit_add(t681, in21);
    let t708 = circuit_mul(t707, in124);
    let t709 = circuit_add(t681, t681);
    let t710 = circuit_add(t709, t709);
    let t711 = circuit_mul(t708, in22);
    let t712 = circuit_add(in132, in124);
    let t713 = circuit_add(t712, in124);
    let t714 = circuit_mul(t713, t710);
    let t715 = circuit_sub(t714, t711);
    let t716 = circuit_mul(t715, t544);
    let t717 = circuit_mul(t716, in104);
    let t718 = circuit_mul(t717, in96);
    let t719 = circuit_add(t696, t718);
    let t720 = circuit_add(in124, in124);
    let t721 = circuit_add(t720, in124);
    let t722 = circuit_mul(t721, in124);
    let t723 = circuit_sub(in124, in132);
    let t724 = circuit_mul(t722, t723);
    let t725 = circuit_add(in125, in125);
    let t726 = circuit_add(in125, in133);
    let t727 = circuit_mul(t725, t726);
    let t728 = circuit_sub(t724, t727);
    let t729 = circuit_mul(t728, t544);
    let t730 = circuit_mul(t729, in104);
    let t731 = circuit_mul(t730, in96);
    let t732 = circuit_add(t706, t731);
    let t733 = circuit_mul(in123, in132);
    let t734 = circuit_mul(in131, in124);
    let t735 = circuit_add(t733, t734);
    let t736 = circuit_mul(in123, in126);
    let t737 = circuit_mul(in124, in125);
    let t738 = circuit_add(t736, t737);
    let t739 = circuit_sub(t738, in133);
    let t740 = circuit_mul(t739, in23);
    let t741 = circuit_sub(t740, in134);
    let t742 = circuit_add(t741, t735);
    let t743 = circuit_mul(t742, in101);
    let t744 = circuit_mul(t735, in23);
    let t745 = circuit_mul(in131, in132);
    let t746 = circuit_add(t744, t745);
    let t747 = circuit_add(in125, in126);
    let t748 = circuit_sub(t746, t747);
    let t749 = circuit_mul(t748, in100);
    let t750 = circuit_add(t746, in126);
    let t751 = circuit_add(in133, in134);
    let t752 = circuit_sub(t750, t751);
    let t753 = circuit_mul(t752, in96);
    let t754 = circuit_add(t749, t743);
    let t755 = circuit_add(t754, t753);
    let t756 = circuit_mul(t755, in99);
    let t757 = circuit_mul(in132, in24);
    let t758 = circuit_add(t757, in131);
    let t759 = circuit_mul(t758, in24);
    let t760 = circuit_add(t759, in125);
    let t761 = circuit_mul(t760, in24);
    let t762 = circuit_add(t761, in124);
    let t763 = circuit_mul(t762, in24);
    let t764 = circuit_add(t763, in123);
    let t765 = circuit_sub(t764, in126);
    let t766 = circuit_mul(t765, in101);
    let t767 = circuit_mul(in133, in24);
    let t768 = circuit_add(t767, in132);
    let t769 = circuit_mul(t768, in24);
    let t770 = circuit_add(t769, in131);
    let t771 = circuit_mul(t770, in24);
    let t772 = circuit_add(t771, in126);
    let t773 = circuit_mul(t772, in24);
    let t774 = circuit_add(t773, in125);
    let t775 = circuit_sub(t774, in134);
    let t776 = circuit_mul(t775, in96);
    let t777 = circuit_add(t766, t776);
    let t778 = circuit_mul(t777, in100);
    let t779 = circuit_mul(in125, in154);
    let t780 = circuit_mul(in124, in153);
    let t781 = circuit_mul(in123, in152);
    let t782 = circuit_add(t779, t780);
    let t783 = circuit_add(t782, t781);
    let t784 = circuit_add(t783, in97);
    let t785 = circuit_sub(t784, in126);
    let t786 = circuit_sub(in131, in123);
    let t787 = circuit_sub(in134, in126);
    let t788 = circuit_mul(t786, t786);
    let t789 = circuit_sub(t788, t786);
    let t790 = circuit_sub(in2, t786);
    let t791 = circuit_add(t790, in0);
    let t792 = circuit_mul(t791, t787);
    let t793 = circuit_mul(in98, in99);
    let t794 = circuit_mul(t793, in105);
    let t795 = circuit_mul(t794, t544);
    let t796 = circuit_mul(t792, t795);
    let t797 = circuit_mul(t789, t795);
    let t798 = circuit_mul(t785, t793);
    let t799 = circuit_sub(in126, t784);
    let t800 = circuit_mul(t799, t799);
    let t801 = circuit_sub(t800, t799);
    let t802 = circuit_mul(in133, in154);
    let t803 = circuit_mul(in132, in153);
    let t804 = circuit_mul(in131, in152);
    let t805 = circuit_add(t802, t803);
    let t806 = circuit_add(t805, t804);
    let t807 = circuit_sub(in134, t806);
    let t808 = circuit_sub(in133, in125);
    let t809 = circuit_sub(in2, t786);
    let t810 = circuit_add(t809, in0);
    let t811 = circuit_sub(in2, t807);
    let t812 = circuit_add(t811, in0);
    let t813 = circuit_mul(t808, t812);
    let t814 = circuit_mul(t810, t813);
    let t815 = circuit_mul(t807, t807);
    let t816 = circuit_sub(t815, t807);
    let t817 = circuit_mul(in102, in105);
    let t818 = circuit_mul(t817, t544);
    let t819 = circuit_mul(t814, t818);
    let t820 = circuit_mul(t789, t818);
    let t821 = circuit_mul(t816, t818);
    let t822 = circuit_mul(t801, in102);
    let t823 = circuit_sub(in132, in124);
    let t824 = circuit_sub(in2, t786);
    let t825 = circuit_add(t824, in0);
    let t826 = circuit_mul(t825, t823);
    let t827 = circuit_sub(t826, in125);
    let t828 = circuit_mul(t827, in101);
    let t829 = circuit_mul(t828, in98);
    let t830 = circuit_add(t798, t829);
    let t831 = circuit_mul(t785, in96);
    let t832 = circuit_mul(t831, in98);
    let t833 = circuit_add(t830, t832);
    let t834 = circuit_add(t833, t822);
    let t835 = circuit_add(t834, t756);
    let t836 = circuit_add(t835, t778);
    let t837 = circuit_mul(t836, in105);
    let t838 = circuit_mul(t837, t544);
    let t839 = circuit_add(in123, in98);
    let t840 = circuit_add(in124, in99);
    let t841 = circuit_add(in125, in100);
    let t842 = circuit_add(in126, in101);
    let t843 = circuit_mul(t839, t839);
    let t844 = circuit_mul(t843, t843);
    let t845 = circuit_mul(t844, t839);
    let t846 = circuit_mul(t840, t840);
    let t847 = circuit_mul(t846, t846);
    let t848 = circuit_mul(t847, t840);
    let t849 = circuit_mul(t841, t841);
    let t850 = circuit_mul(t849, t849);
    let t851 = circuit_mul(t850, t841);
    let t852 = circuit_mul(t842, t842);
    let t853 = circuit_mul(t852, t852);
    let t854 = circuit_mul(t853, t842);
    let t855 = circuit_add(t845, t848);
    let t856 = circuit_add(t851, t854);
    let t857 = circuit_add(t848, t848);
    let t858 = circuit_add(t857, t856);
    let t859 = circuit_add(t854, t854);
    let t860 = circuit_add(t859, t855);
    let t861 = circuit_add(t856, t856);
    let t862 = circuit_add(t861, t861);
    let t863 = circuit_add(t862, t860);
    let t864 = circuit_add(t855, t855);
    let t865 = circuit_add(t864, t864);
    let t866 = circuit_add(t865, t858);
    let t867 = circuit_add(t860, t866);
    let t868 = circuit_add(t858, t863);
    let t869 = circuit_mul(in107, t544);
    let t870 = circuit_sub(t867, in131);
    let t871 = circuit_mul(t869, t870);
    let t872 = circuit_sub(t866, in132);
    let t873 = circuit_mul(t869, t872);
    let t874 = circuit_sub(t868, in133);
    let t875 = circuit_mul(t869, t874);
    let t876 = circuit_sub(t863, in134);
    let t877 = circuit_mul(t869, t876);
    let t878 = circuit_add(in123, in98);
    let t879 = circuit_mul(t878, t878);
    let t880 = circuit_mul(t879, t879);
    let t881 = circuit_mul(t880, t878);
    let t882 = circuit_add(t881, in124);
    let t883 = circuit_add(t882, in125);
    let t884 = circuit_add(t883, in126);
    let t885 = circuit_mul(in108, t544);
    let t886 = circuit_mul(t881, in25);
    let t887 = circuit_add(t886, t884);
    let t888 = circuit_sub(t887, in131);
    let t889 = circuit_mul(t885, t888);
    let t890 = circuit_mul(in124, in26);
    let t891 = circuit_add(t890, t884);
    let t892 = circuit_sub(t891, in132);
    let t893 = circuit_mul(t885, t892);
    let t894 = circuit_mul(in125, in27);
    let t895 = circuit_add(t894, t884);
    let t896 = circuit_sub(t895, in133);
    let t897 = circuit_mul(t885, t896);
    let t898 = circuit_mul(in126, in28);
    let t899 = circuit_add(t898, t884);
    let t900 = circuit_sub(t899, in134);
    let t901 = circuit_mul(t885, t900);
    let t902 = circuit_mul(t572, in158);
    let t903 = circuit_add(t563, t902);
    let t904 = circuit_mul(t609, in159);
    let t905 = circuit_add(t903, t904);
    let t906 = circuit_mul(t611, in160);
    let t907 = circuit_add(t905, t906);
    let t908 = circuit_mul(t640, in161);
    let t909 = circuit_add(t907, t908);
    let t910 = circuit_mul(t643, in162);
    let t911 = circuit_add(t909, t910);
    let t912 = circuit_mul(t655, in163);
    let t913 = circuit_add(t911, t912);
    let t914 = circuit_mul(t663, in164);
    let t915 = circuit_add(t913, t914);
    let t916 = circuit_mul(t671, in165);
    let t917 = circuit_add(t915, t916);
    let t918 = circuit_mul(t679, in166);
    let t919 = circuit_add(t917, t918);
    let t920 = circuit_mul(t719, in167);
    let t921 = circuit_add(t919, t920);
    let t922 = circuit_mul(t732, in168);
    let t923 = circuit_add(t921, t922);
    let t924 = circuit_mul(t838, in169);
    let t925 = circuit_add(t923, t924);
    let t926 = circuit_mul(t796, in170);
    let t927 = circuit_add(t925, t926);
    let t928 = circuit_mul(t797, in171);
    let t929 = circuit_add(t927, t928);
    let t930 = circuit_mul(t819, in172);
    let t931 = circuit_add(t929, t930);
    let t932 = circuit_mul(t820, in173);
    let t933 = circuit_add(t931, t932);
    let t934 = circuit_mul(t821, in174);
    let t935 = circuit_add(t933, t934);
    let t936 = circuit_mul(t871, in175);
    let t937 = circuit_add(t935, t936);
    let t938 = circuit_mul(t873, in176);
    let t939 = circuit_add(t937, t938);
    let t940 = circuit_mul(t875, in177);
    let t941 = circuit_add(t939, t940);
    let t942 = circuit_mul(t877, in178);
    let t943 = circuit_add(t941, t942);
    let t944 = circuit_mul(t889, in179);
    let t945 = circuit_add(t943, t944);
    let t946 = circuit_mul(t893, in180);
    let t947 = circuit_add(t945, t946);
    let t948 = circuit_mul(t897, in181);
    let t949 = circuit_add(t947, t948);
    let t950 = circuit_mul(t901, in182);
    let t951 = circuit_add(t949, t950);
    let t952 = circuit_sub(t951, t540);

    let modulus = get_GRUMPKIN_modulus(); // GRUMPKIN prime field modulus

    let mut circuit_inputs = (t483, t952).new_inputs();
    // Prefill constants:

    circuit_inputs = circuit_inputs
        .next_span(HONK_SUMCHECK_SIZE_8_PUB_2_GRUMPKIN_CONSTANTS.span()); // in0 - in28

    // Fill inputs:

    let mut p_public_inputs = p_public_inputs;
    while let Option::Some(val) = p_public_inputs.pop_front() {
        circuit_inputs = circuit_inputs.next_u256(*val);
    }; // in29 - in30

    circuit_inputs = circuit_inputs.next_2(p_public_inputs_offset); // in31

    let mut sumcheck_univariates_flat = sumcheck_univariates_flat;
    while let Option::Some(val) = sumcheck_univariates_flat.pop_front() {
        circuit_inputs = circuit_inputs.next_u256(*val);
    }; // in32 - in95

    let mut sumcheck_evaluations = sumcheck_evaluations;
    while let Option::Some(val) = sumcheck_evaluations.pop_front() {
        circuit_inputs = circuit_inputs.next_u256(*val);
    }; // in96 - in135

    let mut tp_sum_check_u_challenges = tp_sum_check_u_challenges;
    while let Option::Some(val) = tp_sum_check_u_challenges.pop_front() {
        circuit_inputs = circuit_inputs.next_u128(*val);
    }; // in136 - in143

    let mut tp_gate_challenges = tp_gate_challenges;
    while let Option::Some(val) = tp_gate_challenges.pop_front() {
        circuit_inputs = circuit_inputs.next_u128(*val);
    }; // in144 - in151

    circuit_inputs = circuit_inputs.next_2(tp_eta_1); // in152
    circuit_inputs = circuit_inputs.next_2(tp_eta_2); // in153
    circuit_inputs = circuit_inputs.next_2(tp_eta_3); // in154
    circuit_inputs = circuit_inputs.next_2(tp_beta); // in155
    circuit_inputs = circuit_inputs.next_2(tp_gamma); // in156
    circuit_inputs = circuit_inputs.next_2(tp_base_rlc); // in157

    let mut tp_alphas = tp_alphas;
    while let Option::Some(val) = tp_alphas.pop_front() {
        circuit_inputs = circuit_inputs.next_u128(*val);
    }; // in158 - in182

    let outputs = circuit_inputs.done_2().eval(modulus).unwrap();
    let check_rlc: u384 = outputs.get_output(t483);
    let check: u384 = outputs.get_output(t952);
    return (check_rlc, check);
}
const HONK_SUMCHECK_SIZE_8_PUB_2_GRUMPKIN_CONSTANTS: [u384; 29] = [
    u384 { limb0: 0x1, limb1: 0x0, limb2: 0x0, limb3: 0x0 },
    u384 { limb0: 0x100, limb1: 0x0, limb2: 0x0, limb3: 0x0 },
    u384 { limb0: 0x0, limb1: 0x0, limb2: 0x0, limb3: 0x0 },
    u384 {
        limb0: 0x79b9709143e1f593efffec51,
        limb1: 0xb85045b68181585d2833e848,
        limb2: 0x30644e72e131a029,
        limb3: 0x0,
    },
    u384 { limb0: 0x2d0, limb1: 0x0, limb2: 0x0, limb3: 0x0 },
    u384 {
        limb0: 0x79b9709143e1f593efffff11,
        limb1: 0xb85045b68181585d2833e848,
        limb2: 0x30644e72e131a029,
        limb3: 0x0,
    },
    u384 { limb0: 0x90, limb1: 0x0, limb2: 0x0, limb3: 0x0 },
    u384 {
        limb0: 0x79b9709143e1f593efffff71,
        limb1: 0xb85045b68181585d2833e848,
        limb2: 0x30644e72e131a029,
        limb3: 0x0,
    },
    u384 { limb0: 0xf0, limb1: 0x0, limb2: 0x0, limb3: 0x0 },
    u384 {
        limb0: 0x79b9709143e1f593effffd31,
        limb1: 0xb85045b68181585d2833e848,
        limb2: 0x30644e72e131a029,
        limb3: 0x0,
    },
    u384 { limb0: 0x13b0, limb1: 0x0, limb2: 0x0, limb3: 0x0 },
    u384 { limb0: 0x2, limb1: 0x0, limb2: 0x0, limb3: 0x0 },
    u384 { limb0: 0x3, limb1: 0x0, limb2: 0x0, limb3: 0x0 },
    u384 { limb0: 0x4, limb1: 0x0, limb2: 0x0, limb3: 0x0 },
    u384 { limb0: 0x5, limb1: 0x0, limb2: 0x0, limb3: 0x0 },
    u384 { limb0: 0x6, limb1: 0x0, limb2: 0x0, limb3: 0x0 },
    u384 { limb0: 0x7, limb1: 0x0, limb2: 0x0, limb3: 0x0 },
    u384 {
        limb0: 0x3cdcb848a1f0fac9f8000000,
        limb1: 0xdc2822db40c0ac2e9419f424,
        limb2: 0x183227397098d014,
        limb3: 0x0,
    },
    u384 {
        limb0: 0x79b9709143e1f593f0000000,
        limb1: 0xb85045b68181585d2833e848,
        limb2: 0x30644e72e131a029,
        limb3: 0x0,
    },
    u384 {
        limb0: 0x79b9709143e1f593efffffff,
        limb1: 0xb85045b68181585d2833e848,
        limb2: 0x30644e72e131a029,
        limb3: 0x0,
    },
    u384 {
        limb0: 0x79b9709143e1f593effffffe,
        limb1: 0xb85045b68181585d2833e848,
        limb2: 0x30644e72e131a029,
        limb3: 0x0,
    },
    u384 { limb0: 0x11, limb1: 0x0, limb2: 0x0, limb3: 0x0 },
    u384 { limb0: 0x9, limb1: 0x0, limb2: 0x0, limb3: 0x0 },
    u384 { limb0: 0x100000000000000000, limb1: 0x0, limb2: 0x0, limb3: 0x0 },
    u384 { limb0: 0x4000, limb1: 0x0, limb2: 0x0, limb3: 0x0 },
    u384 {
        limb0: 0x29ca1d7fb56821fd19d3b6e7,
        limb1: 0x4b1e03b4bd9490c0d03f989,
        limb2: 0x10dc6e9c006ea38b,
        limb3: 0x0,
    },
    u384 {
        limb0: 0xd4dd9b84a86b38cfb45a740b,
        limb1: 0x149b3d0a30b3bb599df9756,
        limb2: 0xc28145b6a44df3e,
        limb3: 0x0,
    },
    u384 {
        limb0: 0x60e3596170067d00141cac15,
        limb1: 0xb2c7645a50392798b21f75bb,
        limb2: 0x544b8338791518,
        limb3: 0x0,
    },
    u384 {
        limb0: 0xb8fa852613bc534433ee428b,
        limb1: 0x2e2e82eb122789e352e105a3,
        limb2: 0x222c01175718386f,
        limb3: 0x0,
    },
];
#[inline(always)]
pub fn run_GRUMPKIN_HONK_PREP_MSM_SCALARS_SIZE_8_circuit(
    p_sumcheck_evaluations: Span<u256>,
    p_gemini_a_evaluations: Span<u256>,
    tp_gemini_r: u384,
    tp_rho: u384,
    tp_shplonk_z: u384,
    tp_shplonk_nu: u384,
    tp_sum_check_u_challenges: Span<u128>,
) -> (
    u384,
    u384,
    u384,
    u384,
    u384,
    u384,
    u384,
    u384,
    u384,
    u384,
    u384,
    u384,
    u384,
    u384,
    u384,
    u384,
    u384,
    u384,
    u384,
    u384,
    u384,
    u384,
    u384,
    u384,
    u384,
    u384,
    u384,
    u384,
    u384,
    u384,
    u384,
    u384,
    u384,
    u384,
    u384,
    u384,
    u384,
    u384,
    u384,
    u384,
    u384,
    u384,
    u384,
    u384,
    u384,
) {
    // CONSTANT stack
    let in0 = CE::<CI<0>> {}; // 0x0
    let in1 = CE::<CI<1>> {}; // 0x1

    // INPUT stack
    let (in2, in3, in4) = (CE::<CI<2>> {}, CE::<CI<3>> {}, CE::<CI<4>> {});
    let (in5, in6, in7) = (CE::<CI<5>> {}, CE::<CI<6>> {}, CE::<CI<7>> {});
    let (in8, in9, in10) = (CE::<CI<8>> {}, CE::<CI<9>> {}, CE::<CI<10>> {});
    let (in11, in12, in13) = (CE::<CI<11>> {}, CE::<CI<12>> {}, CE::<CI<13>> {});
    let (in14, in15, in16) = (CE::<CI<14>> {}, CE::<CI<15>> {}, CE::<CI<16>> {});
    let (in17, in18, in19) = (CE::<CI<17>> {}, CE::<CI<18>> {}, CE::<CI<19>> {});
    let (in20, in21, in22) = (CE::<CI<20>> {}, CE::<CI<21>> {}, CE::<CI<22>> {});
    let (in23, in24, in25) = (CE::<CI<23>> {}, CE::<CI<24>> {}, CE::<CI<25>> {});
    let (in26, in27, in28) = (CE::<CI<26>> {}, CE::<CI<27>> {}, CE::<CI<28>> {});
    let (in29, in30, in31) = (CE::<CI<29>> {}, CE::<CI<30>> {}, CE::<CI<31>> {});
    let (in32, in33, in34) = (CE::<CI<32>> {}, CE::<CI<33>> {}, CE::<CI<34>> {});
    let (in35, in36, in37) = (CE::<CI<35>> {}, CE::<CI<36>> {}, CE::<CI<37>> {});
    let (in38, in39, in40) = (CE::<CI<38>> {}, CE::<CI<39>> {}, CE::<CI<40>> {});
    let (in41, in42, in43) = (CE::<CI<41>> {}, CE::<CI<42>> {}, CE::<CI<43>> {});
    let (in44, in45, in46) = (CE::<CI<44>> {}, CE::<CI<45>> {}, CE::<CI<46>> {});
    let (in47, in48, in49) = (CE::<CI<47>> {}, CE::<CI<48>> {}, CE::<CI<49>> {});
    let (in50, in51, in52) = (CE::<CI<50>> {}, CE::<CI<51>> {}, CE::<CI<52>> {});
    let (in53, in54, in55) = (CE::<CI<53>> {}, CE::<CI<54>> {}, CE::<CI<55>> {});
    let (in56, in57, in58) = (CE::<CI<56>> {}, CE::<CI<57>> {}, CE::<CI<58>> {});
    let (in59, in60, in61) = (CE::<CI<59>> {}, CE::<CI<60>> {}, CE::<CI<61>> {});
    let (in62, in63, in64) = (CE::<CI<62>> {}, CE::<CI<63>> {}, CE::<CI<64>> {});
    let in65 = CE::<CI<65>> {};
    let t0 = circuit_mul(in54, in54);
    let t1 = circuit_mul(t0, t0);
    let t2 = circuit_mul(t1, t1);
    let t3 = circuit_mul(t2, t2);
    let t4 = circuit_mul(t3, t3);
    let t5 = circuit_mul(t4, t4);
    let t6 = circuit_mul(t5, t5);
    let t7 = circuit_sub(in56, in54);
    let t8 = circuit_inverse(t7);
    let t9 = circuit_add(in56, in54);
    let t10 = circuit_inverse(t9);
    let t11 = circuit_add(in56, t0);
    let t12 = circuit_inverse(t11);
    let t13 = circuit_add(in56, t1);
    let t14 = circuit_inverse(t13);
    let t15 = circuit_add(in56, t2);
    let t16 = circuit_inverse(t15);
    let t17 = circuit_add(in56, t3);
    let t18 = circuit_inverse(t17);
    let t19 = circuit_add(in56, t4);
    let t20 = circuit_inverse(t19);
    let t21 = circuit_add(in56, t5);
    let t22 = circuit_inverse(t21);
    let t23 = circuit_add(in56, t6);
    let t24 = circuit_inverse(t23);
    let t25 = circuit_mul(in57, t10);
    let t26 = circuit_add(t8, t25);
    let t27 = circuit_sub(in0, t26);
    let t28 = circuit_inverse(in54);
    let t29 = circuit_mul(in57, t10);
    let t30 = circuit_sub(t8, t29);
    let t31 = circuit_mul(t28, t30);
    let t32 = circuit_sub(in0, t31);
    let t33 = circuit_mul(t27, in1);
    let t34 = circuit_mul(in2, in1);
    let t35 = circuit_add(in0, t34);
    let t36 = circuit_mul(in1, in55);
    let t37 = circuit_mul(t27, t36);
    let t38 = circuit_mul(in3, t36);
    let t39 = circuit_add(t35, t38);
    let t40 = circuit_mul(t36, in55);
    let t41 = circuit_mul(t27, t40);
    let t42 = circuit_mul(in4, t40);
    let t43 = circuit_add(t39, t42);
    let t44 = circuit_mul(t40, in55);
    let t45 = circuit_mul(t27, t44);
    let t46 = circuit_mul(in5, t44);
    let t47 = circuit_add(t43, t46);
    let t48 = circuit_mul(t44, in55);
    let t49 = circuit_mul(t27, t48);
    let t50 = circuit_mul(in6, t48);
    let t51 = circuit_add(t47, t50);
    let t52 = circuit_mul(t48, in55);
    let t53 = circuit_mul(t27, t52);
    let t54 = circuit_mul(in7, t52);
    let t55 = circuit_add(t51, t54);
    let t56 = circuit_mul(t52, in55);
    let t57 = circuit_mul(t27, t56);
    let t58 = circuit_mul(in8, t56);
    let t59 = circuit_add(t55, t58);
    let t60 = circuit_mul(t56, in55);
    let t61 = circuit_mul(t27, t60);
    let t62 = circuit_mul(in9, t60);
    let t63 = circuit_add(t59, t62);
    let t64 = circuit_mul(t60, in55);
    let t65 = circuit_mul(t27, t64);
    let t66 = circuit_mul(in10, t64);
    let t67 = circuit_add(t63, t66);
    let t68 = circuit_mul(t64, in55);
    let t69 = circuit_mul(t27, t68);
    let t70 = circuit_mul(in11, t68);
    let t71 = circuit_add(t67, t70);
    let t72 = circuit_mul(t68, in55);
    let t73 = circuit_mul(t27, t72);
    let t74 = circuit_mul(in12, t72);
    let t75 = circuit_add(t71, t74);
    let t76 = circuit_mul(t72, in55);
    let t77 = circuit_mul(t27, t76);
    let t78 = circuit_mul(in13, t76);
    let t79 = circuit_add(t75, t78);
    let t80 = circuit_mul(t76, in55);
    let t81 = circuit_mul(t27, t80);
    let t82 = circuit_mul(in14, t80);
    let t83 = circuit_add(t79, t82);
    let t84 = circuit_mul(t80, in55);
    let t85 = circuit_mul(t27, t84);
    let t86 = circuit_mul(in15, t84);
    let t87 = circuit_add(t83, t86);
    let t88 = circuit_mul(t84, in55);
    let t89 = circuit_mul(t27, t88);
    let t90 = circuit_mul(in16, t88);
    let t91 = circuit_add(t87, t90);
    let t92 = circuit_mul(t88, in55);
    let t93 = circuit_mul(t27, t92);
    let t94 = circuit_mul(in17, t92);
    let t95 = circuit_add(t91, t94);
    let t96 = circuit_mul(t92, in55);
    let t97 = circuit_mul(t27, t96);
    let t98 = circuit_mul(in18, t96);
    let t99 = circuit_add(t95, t98);
    let t100 = circuit_mul(t96, in55);
    let t101 = circuit_mul(t27, t100);
    let t102 = circuit_mul(in19, t100);
    let t103 = circuit_add(t99, t102);
    let t104 = circuit_mul(t100, in55);
    let t105 = circuit_mul(t27, t104);
    let t106 = circuit_mul(in20, t104);
    let t107 = circuit_add(t103, t106);
    let t108 = circuit_mul(t104, in55);
    let t109 = circuit_mul(t27, t108);
    let t110 = circuit_mul(in21, t108);
    let t111 = circuit_add(t107, t110);
    let t112 = circuit_mul(t108, in55);
    let t113 = circuit_mul(t27, t112);
    let t114 = circuit_mul(in22, t112);
    let t115 = circuit_add(t111, t114);
    let t116 = circuit_mul(t112, in55);
    let t117 = circuit_mul(t27, t116);
    let t118 = circuit_mul(in23, t116);
    let t119 = circuit_add(t115, t118);
    let t120 = circuit_mul(t116, in55);
    let t121 = circuit_mul(t27, t120);
    let t122 = circuit_mul(in24, t120);
    let t123 = circuit_add(t119, t122);
    let t124 = circuit_mul(t120, in55);
    let t125 = circuit_mul(t27, t124);
    let t126 = circuit_mul(in25, t124);
    let t127 = circuit_add(t123, t126);
    let t128 = circuit_mul(t124, in55);
    let t129 = circuit_mul(t27, t128);
    let t130 = circuit_mul(in26, t128);
    let t131 = circuit_add(t127, t130);
    let t132 = circuit_mul(t128, in55);
    let t133 = circuit_mul(t27, t132);
    let t134 = circuit_mul(in27, t132);
    let t135 = circuit_add(t131, t134);
    let t136 = circuit_mul(t132, in55);
    let t137 = circuit_mul(t27, t136);
    let t138 = circuit_mul(in28, t136);
    let t139 = circuit_add(t135, t138);
    let t140 = circuit_mul(t136, in55);
    let t141 = circuit_mul(t27, t140);
    let t142 = circuit_mul(in29, t140);
    let t143 = circuit_add(t139, t142);
    let t144 = circuit_mul(t140, in55);
    let t145 = circuit_mul(t27, t144);
    let t146 = circuit_mul(in30, t144);
    let t147 = circuit_add(t143, t146);
    let t148 = circuit_mul(t144, in55);
    let t149 = circuit_mul(t27, t148);
    let t150 = circuit_mul(in31, t148);
    let t151 = circuit_add(t147, t150);
    let t152 = circuit_mul(t148, in55);
    let t153 = circuit_mul(t27, t152);
    let t154 = circuit_mul(in32, t152);
    let t155 = circuit_add(t151, t154);
    let t156 = circuit_mul(t152, in55);
    let t157 = circuit_mul(t27, t156);
    let t158 = circuit_mul(in33, t156);
    let t159 = circuit_add(t155, t158);
    let t160 = circuit_mul(t156, in55);
    let t161 = circuit_mul(t27, t160);
    let t162 = circuit_mul(in34, t160);
    let t163 = circuit_add(t159, t162);
    let t164 = circuit_mul(t160, in55);
    let t165 = circuit_mul(t27, t164);
    let t166 = circuit_mul(in35, t164);
    let t167 = circuit_add(t163, t166);
    let t168 = circuit_mul(t164, in55);
    let t169 = circuit_mul(t27, t168);
    let t170 = circuit_mul(in36, t168);
    let t171 = circuit_add(t167, t170);
    let t172 = circuit_mul(t168, in55);
    let t173 = circuit_mul(t32, t172);
    let t174 = circuit_mul(in37, t172);
    let t175 = circuit_add(t171, t174);
    let t176 = circuit_mul(t172, in55);
    let t177 = circuit_mul(t32, t176);
    let t178 = circuit_mul(in38, t176);
    let t179 = circuit_add(t175, t178);
    let t180 = circuit_mul(t176, in55);
    let t181 = circuit_mul(t32, t180);
    let t182 = circuit_mul(in39, t180);
    let t183 = circuit_add(t179, t182);
    let t184 = circuit_mul(t180, in55);
    let t185 = circuit_mul(t32, t184);
    let t186 = circuit_mul(in40, t184);
    let t187 = circuit_add(t183, t186);
    let t188 = circuit_mul(t184, in55);
    let t189 = circuit_mul(t32, t188);
    let t190 = circuit_mul(in41, t188);
    let t191 = circuit_add(t187, t190);
    let t192 = circuit_mul(t188, in55);
    let t193 = circuit_mul(t32, t192);
    let t194 = circuit_mul(in42, t192);
    let t195 = circuit_add(t191, t194);
    let t196 = circuit_mul(t192, in55);
    let t197 = circuit_mul(t32, t196);
    let t198 = circuit_mul(in43, t196);
    let t199 = circuit_add(t195, t198);
    let t200 = circuit_mul(t196, in55);
    let t201 = circuit_mul(t32, t200);
    let t202 = circuit_mul(in44, t200);
    let t203 = circuit_add(t199, t202);
    let t204 = circuit_mul(t200, in55);
    let t205 = circuit_mul(t32, t204);
    let t206 = circuit_mul(in45, t204);
    let t207 = circuit_add(t203, t206);
    let t208 = circuit_mul(in57, in57);
    let t209 = circuit_mul(t208, t12);
    let t210 = circuit_sub(in0, t209);
    let t211 = circuit_mul(t209, in47);
    let t212 = circuit_add(in0, t211);
    let t213 = circuit_mul(t208, in57);
    let t214 = circuit_mul(t213, t14);
    let t215 = circuit_sub(in0, t214);
    let t216 = circuit_mul(t214, in48);
    let t217 = circuit_add(t212, t216);
    let t218 = circuit_mul(t213, in57);
    let t219 = circuit_mul(t218, t16);
    let t220 = circuit_sub(in0, t219);
    let t221 = circuit_mul(t219, in49);
    let t222 = circuit_add(t217, t221);
    let t223 = circuit_mul(t218, in57);
    let t224 = circuit_mul(t223, t18);
    let t225 = circuit_sub(in0, t224);
    let t226 = circuit_mul(t224, in50);
    let t227 = circuit_add(t222, t226);
    let t228 = circuit_mul(t223, in57);
    let t229 = circuit_mul(t228, t20);
    let t230 = circuit_sub(in0, t229);
    let t231 = circuit_mul(t229, in51);
    let t232 = circuit_add(t227, t231);
    let t233 = circuit_mul(t228, in57);
    let t234 = circuit_mul(t233, t22);
    let t235 = circuit_sub(in0, t234);
    let t236 = circuit_mul(t234, in52);
    let t237 = circuit_add(t232, t236);
    let t238 = circuit_mul(t233, in57);
    let t239 = circuit_mul(t238, t24);
    let t240 = circuit_sub(in0, t239);
    let t241 = circuit_mul(t239, in53);
    let t242 = circuit_add(t237, t241);
    let t243 = circuit_sub(in1, in65);
    let t244 = circuit_mul(t6, t243);
    let t245 = circuit_mul(t6, t207);
    let t246 = circuit_add(t245, t245);
    let t247 = circuit_sub(t244, in65);
    let t248 = circuit_mul(in53, t247);
    let t249 = circuit_sub(t246, t248);
    let t250 = circuit_add(t244, in65);
    let t251 = circuit_inverse(t250);
    let t252 = circuit_mul(t249, t251);
    let t253 = circuit_sub(in1, in64);
    let t254 = circuit_mul(t5, t253);
    let t255 = circuit_mul(t5, t252);
    let t256 = circuit_add(t255, t255);
    let t257 = circuit_sub(t254, in64);
    let t258 = circuit_mul(in52, t257);
    let t259 = circuit_sub(t256, t258);
    let t260 = circuit_add(t254, in64);
    let t261 = circuit_inverse(t260);
    let t262 = circuit_mul(t259, t261);
    let t263 = circuit_sub(in1, in63);
    let t264 = circuit_mul(t4, t263);
    let t265 = circuit_mul(t4, t262);
    let t266 = circuit_add(t265, t265);
    let t267 = circuit_sub(t264, in63);
    let t268 = circuit_mul(in51, t267);
    let t269 = circuit_sub(t266, t268);
    let t270 = circuit_add(t264, in63);
    let t271 = circuit_inverse(t270);
    let t272 = circuit_mul(t269, t271);
    let t273 = circuit_sub(in1, in62);
    let t274 = circuit_mul(t3, t273);
    let t275 = circuit_mul(t3, t272);
    let t276 = circuit_add(t275, t275);
    let t277 = circuit_sub(t274, in62);
    let t278 = circuit_mul(in50, t277);
    let t279 = circuit_sub(t276, t278);
    let t280 = circuit_add(t274, in62);
    let t281 = circuit_inverse(t280);
    let t282 = circuit_mul(t279, t281);
    let t283 = circuit_sub(in1, in61);
    let t284 = circuit_mul(t2, t283);
    let t285 = circuit_mul(t2, t282);
    let t286 = circuit_add(t285, t285);
    let t287 = circuit_sub(t284, in61);
    let t288 = circuit_mul(in49, t287);
    let t289 = circuit_sub(t286, t288);
    let t290 = circuit_add(t284, in61);
    let t291 = circuit_inverse(t290);
    let t292 = circuit_mul(t289, t291);
    let t293 = circuit_sub(in1, in60);
    let t294 = circuit_mul(t1, t293);
    let t295 = circuit_mul(t1, t292);
    let t296 = circuit_add(t295, t295);
    let t297 = circuit_sub(t294, in60);
    let t298 = circuit_mul(in48, t297);
    let t299 = circuit_sub(t296, t298);
    let t300 = circuit_add(t294, in60);
    let t301 = circuit_inverse(t300);
    let t302 = circuit_mul(t299, t301);
    let t303 = circuit_sub(in1, in59);
    let t304 = circuit_mul(t0, t303);
    let t305 = circuit_mul(t0, t302);
    let t306 = circuit_add(t305, t305);
    let t307 = circuit_sub(t304, in59);
    let t308 = circuit_mul(in47, t307);
    let t309 = circuit_sub(t306, t308);
    let t310 = circuit_add(t304, in59);
    let t311 = circuit_inverse(t310);
    let t312 = circuit_mul(t309, t311);
    let t313 = circuit_sub(in1, in58);
    let t314 = circuit_mul(in54, t313);
    let t315 = circuit_mul(in54, t312);
    let t316 = circuit_add(t315, t315);
    let t317 = circuit_sub(t314, in58);
    let t318 = circuit_mul(in46, t317);
    let t319 = circuit_sub(t316, t318);
    let t320 = circuit_add(t314, in58);
    let t321 = circuit_inverse(t320);
    let t322 = circuit_mul(t319, t321);
    let t323 = circuit_mul(t322, t8);
    let t324 = circuit_add(t242, t323);
    let t325 = circuit_mul(in46, in57);
    let t326 = circuit_mul(t325, t10);
    let t327 = circuit_add(t324, t326);
    let t328 = circuit_add(t117, t173);
    let t329 = circuit_add(t121, t177);
    let t330 = circuit_add(t125, t181);
    let t331 = circuit_add(t129, t185);
    let t332 = circuit_add(t141, t189);
    let t333 = circuit_add(t145, t193);
    let t334 = circuit_add(t149, t197);
    let t335 = circuit_add(t153, t201);
    let t336 = circuit_add(t33, t37);
    let t337 = circuit_add(t336, t41);
    let t338 = circuit_add(t337, t45);
    let t339 = circuit_add(t338, t49);
    let t340 = circuit_add(t339, t53);
    let t341 = circuit_add(t340, t57);
    let t342 = circuit_add(t341, t61);
    let t343 = circuit_add(t342, t65);
    let t344 = circuit_add(t343, t69);
    let t345 = circuit_add(t344, t73);
    let t346 = circuit_add(t345, t77);
    let t347 = circuit_add(t346, t81);
    let t348 = circuit_add(t347, t85);
    let t349 = circuit_add(t348, t89);
    let t350 = circuit_add(t349, t93);
    let t351 = circuit_add(t350, t97);
    let t352 = circuit_add(t351, t101);
    let t353 = circuit_add(t352, t105);
    let t354 = circuit_add(t353, t109);
    let t355 = circuit_add(t354, t113);
    let t356 = circuit_add(t355, t328);
    let t357 = circuit_add(t356, t329);
    let t358 = circuit_add(t357, t330);
    let t359 = circuit_add(t358, t331);
    let t360 = circuit_add(t359, t133);
    let t361 = circuit_add(t360, t137);
    let t362 = circuit_add(t361, t332);
    let t363 = circuit_add(t362, t333);
    let t364 = circuit_add(t363, t334);
    let t365 = circuit_add(t364, t335);
    let t366 = circuit_add(t365, t157);
    let t367 = circuit_add(t366, t161);
    let t368 = circuit_add(t367, t165);
    let t369 = circuit_add(t368, t169);
    let t370 = circuit_add(t369, t205);
    let t371 = circuit_add(t370, t210);
    let t372 = circuit_add(t371, t215);
    let t373 = circuit_add(t372, t220);
    let t374 = circuit_add(t373, t225);
    let t375 = circuit_add(t374, t230);
    let t376 = circuit_add(t375, t235);
    let t377 = circuit_add(t376, t240);
    let t378 = circuit_add(t377, t327);

    let modulus = get_GRUMPKIN_modulus(); // GRUMPKIN prime field modulus

    let mut circuit_inputs = (t378,).new_inputs();
    // Prefill constants:
    circuit_inputs = circuit_inputs.next_2([0x0, 0x0, 0x0, 0x0]); // in0
    circuit_inputs = circuit_inputs.next_2([0x1, 0x0, 0x0, 0x0]); // in1
    // Fill inputs:

    let mut p_sumcheck_evaluations = p_sumcheck_evaluations;
    while let Option::Some(val) = p_sumcheck_evaluations.pop_front() {
        circuit_inputs = circuit_inputs.next_u256(*val);
    }; // in2 - in45

    let mut p_gemini_a_evaluations = p_gemini_a_evaluations;
    while let Option::Some(val) = p_gemini_a_evaluations.pop_front() {
        circuit_inputs = circuit_inputs.next_u256(*val);
    }; // in46 - in53

    circuit_inputs = circuit_inputs.next_2(tp_gemini_r); // in54
    circuit_inputs = circuit_inputs.next_2(tp_rho); // in55
    circuit_inputs = circuit_inputs.next_2(tp_shplonk_z); // in56
    circuit_inputs = circuit_inputs.next_2(tp_shplonk_nu); // in57

    let mut tp_sum_check_u_challenges = tp_sum_check_u_challenges;
    while let Option::Some(val) = tp_sum_check_u_challenges.pop_front() {
        circuit_inputs = circuit_inputs.next_u128(*val);
    }; // in58 - in65

    let outputs = circuit_inputs.done_2().eval(modulus).unwrap();
    let scalar_1: u384 = outputs.get_output(t33);
    let scalar_2: u384 = outputs.get_output(t37);
    let scalar_3: u384 = outputs.get_output(t41);
    let scalar_4: u384 = outputs.get_output(t45);
    let scalar_5: u384 = outputs.get_output(t49);
    let scalar_6: u384 = outputs.get_output(t53);
    let scalar_7: u384 = outputs.get_output(t57);
    let scalar_8: u384 = outputs.get_output(t61);
    let scalar_9: u384 = outputs.get_output(t65);
    let scalar_10: u384 = outputs.get_output(t69);
    let scalar_11: u384 = outputs.get_output(t73);
    let scalar_12: u384 = outputs.get_output(t77);
    let scalar_13: u384 = outputs.get_output(t81);
    let scalar_14: u384 = outputs.get_output(t85);
    let scalar_15: u384 = outputs.get_output(t89);
    let scalar_16: u384 = outputs.get_output(t93);
    let scalar_17: u384 = outputs.get_output(t97);
    let scalar_18: u384 = outputs.get_output(t101);
    let scalar_19: u384 = outputs.get_output(t105);
    let scalar_20: u384 = outputs.get_output(t109);
    let scalar_21: u384 = outputs.get_output(t113);
    let scalar_22: u384 = outputs.get_output(t328);
    let scalar_23: u384 = outputs.get_output(t329);
    let scalar_24: u384 = outputs.get_output(t330);
    let scalar_25: u384 = outputs.get_output(t331);
    let scalar_26: u384 = outputs.get_output(t133);
    let scalar_27: u384 = outputs.get_output(t137);
    let scalar_28: u384 = outputs.get_output(t332);
    let scalar_29: u384 = outputs.get_output(t333);
    let scalar_30: u384 = outputs.get_output(t334);
    let scalar_31: u384 = outputs.get_output(t335);
    let scalar_32: u384 = outputs.get_output(t157);
    let scalar_33: u384 = outputs.get_output(t161);
    let scalar_34: u384 = outputs.get_output(t165);
    let scalar_35: u384 = outputs.get_output(t169);
    let scalar_44: u384 = outputs.get_output(t205);
    let scalar_45: u384 = outputs.get_output(t210);
    let scalar_46: u384 = outputs.get_output(t215);
    let scalar_47: u384 = outputs.get_output(t220);
    let scalar_48: u384 = outputs.get_output(t225);
    let scalar_49: u384 = outputs.get_output(t230);
    let scalar_50: u384 = outputs.get_output(t235);
    let scalar_51: u384 = outputs.get_output(t240);
    let scalar_72: u384 = outputs.get_output(t327);
    let sum_scalars: u384 = outputs.get_output(t378);
    return (
        scalar_1,
        scalar_2,
        scalar_3,
        scalar_4,
        scalar_5,
        scalar_6,
        scalar_7,
        scalar_8,
        scalar_9,
        scalar_10,
        scalar_11,
        scalar_12,
        scalar_13,
        scalar_14,
        scalar_15,
        scalar_16,
        scalar_17,
        scalar_18,
        scalar_19,
        scalar_20,
        scalar_21,
        scalar_22,
        scalar_23,
        scalar_24,
        scalar_25,
        scalar_26,
        scalar_27,
        scalar_28,
        scalar_29,
        scalar_30,
        scalar_31,
        scalar_32,
        scalar_33,
        scalar_34,
        scalar_35,
        scalar_44,
        scalar_45,
        scalar_46,
        scalar_47,
        scalar_48,
        scalar_49,
        scalar_50,
        scalar_51,
        scalar_72,
        sum_scalars,
    );
}
#[inline(always)]
pub fn run_BN254_EVAL_FN_CHALLENGE_DUPL_45P_RLC_circuit(
    A0: G1Point, A2: G1Point, coeff0: u384, coeff2: u384, SumDlogDivBatched: FunctionFelt,
) -> (u384,) {
    // INPUT stack
    let (in0, in1, in2) = (CE::<CI<0>> {}, CE::<CI<1>> {}, CE::<CI<2>> {});
    let (in3, in4, in5) = (CE::<CI<3>> {}, CE::<CI<4>> {}, CE::<CI<5>> {});
    let (in6, in7, in8) = (CE::<CI<6>> {}, CE::<CI<7>> {}, CE::<CI<8>> {});
    let (in9, in10, in11) = (CE::<CI<9>> {}, CE::<CI<10>> {}, CE::<CI<11>> {});
    let (in12, in13, in14) = (CE::<CI<12>> {}, CE::<CI<13>> {}, CE::<CI<14>> {});
    let (in15, in16, in17) = (CE::<CI<15>> {}, CE::<CI<16>> {}, CE::<CI<17>> {});
    let (in18, in19, in20) = (CE::<CI<18>> {}, CE::<CI<19>> {}, CE::<CI<20>> {});
    let (in21, in22, in23) = (CE::<CI<21>> {}, CE::<CI<22>> {}, CE::<CI<23>> {});
    let (in24, in25, in26) = (CE::<CI<24>> {}, CE::<CI<25>> {}, CE::<CI<26>> {});
    let (in27, in28, in29) = (CE::<CI<27>> {}, CE::<CI<28>> {}, CE::<CI<29>> {});
    let (in30, in31, in32) = (CE::<CI<30>> {}, CE::<CI<31>> {}, CE::<CI<32>> {});
    let (in33, in34, in35) = (CE::<CI<33>> {}, CE::<CI<34>> {}, CE::<CI<35>> {});
    let (in36, in37, in38) = (CE::<CI<36>> {}, CE::<CI<37>> {}, CE::<CI<38>> {});
    let (in39, in40, in41) = (CE::<CI<39>> {}, CE::<CI<40>> {}, CE::<CI<41>> {});
    let (in42, in43, in44) = (CE::<CI<42>> {}, CE::<CI<43>> {}, CE::<CI<44>> {});
    let (in45, in46, in47) = (CE::<CI<45>> {}, CE::<CI<46>> {}, CE::<CI<47>> {});
    let (in48, in49, in50) = (CE::<CI<48>> {}, CE::<CI<49>> {}, CE::<CI<50>> {});
    let (in51, in52, in53) = (CE::<CI<51>> {}, CE::<CI<52>> {}, CE::<CI<53>> {});
    let (in54, in55, in56) = (CE::<CI<54>> {}, CE::<CI<55>> {}, CE::<CI<56>> {});
    let (in57, in58, in59) = (CE::<CI<57>> {}, CE::<CI<58>> {}, CE::<CI<59>> {});
    let (in60, in61, in62) = (CE::<CI<60>> {}, CE::<CI<61>> {}, CE::<CI<62>> {});
    let (in63, in64, in65) = (CE::<CI<63>> {}, CE::<CI<64>> {}, CE::<CI<65>> {});
    let (in66, in67, in68) = (CE::<CI<66>> {}, CE::<CI<67>> {}, CE::<CI<68>> {});
    let (in69, in70, in71) = (CE::<CI<69>> {}, CE::<CI<70>> {}, CE::<CI<71>> {});
    let (in72, in73, in74) = (CE::<CI<72>> {}, CE::<CI<73>> {}, CE::<CI<74>> {});
    let (in75, in76, in77) = (CE::<CI<75>> {}, CE::<CI<76>> {}, CE::<CI<77>> {});
    let (in78, in79, in80) = (CE::<CI<78>> {}, CE::<CI<79>> {}, CE::<CI<80>> {});
    let (in81, in82, in83) = (CE::<CI<81>> {}, CE::<CI<82>> {}, CE::<CI<83>> {});
    let (in84, in85, in86) = (CE::<CI<84>> {}, CE::<CI<85>> {}, CE::<CI<86>> {});
    let (in87, in88, in89) = (CE::<CI<87>> {}, CE::<CI<88>> {}, CE::<CI<89>> {});
    let (in90, in91, in92) = (CE::<CI<90>> {}, CE::<CI<91>> {}, CE::<CI<92>> {});
    let (in93, in94, in95) = (CE::<CI<93>> {}, CE::<CI<94>> {}, CE::<CI<95>> {});
    let (in96, in97, in98) = (CE::<CI<96>> {}, CE::<CI<97>> {}, CE::<CI<98>> {});
    let (in99, in100, in101) = (CE::<CI<99>> {}, CE::<CI<100>> {}, CE::<CI<101>> {});
    let (in102, in103, in104) = (CE::<CI<102>> {}, CE::<CI<103>> {}, CE::<CI<104>> {});
    let (in105, in106, in107) = (CE::<CI<105>> {}, CE::<CI<106>> {}, CE::<CI<107>> {});
    let (in108, in109, in110) = (CE::<CI<108>> {}, CE::<CI<109>> {}, CE::<CI<110>> {});
    let (in111, in112, in113) = (CE::<CI<111>> {}, CE::<CI<112>> {}, CE::<CI<113>> {});
    let (in114, in115, in116) = (CE::<CI<114>> {}, CE::<CI<115>> {}, CE::<CI<116>> {});
    let (in117, in118, in119) = (CE::<CI<117>> {}, CE::<CI<118>> {}, CE::<CI<119>> {});
    let (in120, in121, in122) = (CE::<CI<120>> {}, CE::<CI<121>> {}, CE::<CI<122>> {});
    let (in123, in124, in125) = (CE::<CI<123>> {}, CE::<CI<124>> {}, CE::<CI<125>> {});
    let (in126, in127, in128) = (CE::<CI<126>> {}, CE::<CI<127>> {}, CE::<CI<128>> {});
    let (in129, in130, in131) = (CE::<CI<129>> {}, CE::<CI<130>> {}, CE::<CI<131>> {});
    let (in132, in133, in134) = (CE::<CI<132>> {}, CE::<CI<133>> {}, CE::<CI<134>> {});
    let (in135, in136, in137) = (CE::<CI<135>> {}, CE::<CI<136>> {}, CE::<CI<137>> {});
    let (in138, in139, in140) = (CE::<CI<138>> {}, CE::<CI<139>> {}, CE::<CI<140>> {});
    let (in141, in142, in143) = (CE::<CI<141>> {}, CE::<CI<142>> {}, CE::<CI<143>> {});
    let (in144, in145, in146) = (CE::<CI<144>> {}, CE::<CI<145>> {}, CE::<CI<146>> {});
    let (in147, in148, in149) = (CE::<CI<147>> {}, CE::<CI<148>> {}, CE::<CI<149>> {});
    let (in150, in151, in152) = (CE::<CI<150>> {}, CE::<CI<151>> {}, CE::<CI<152>> {});
    let (in153, in154, in155) = (CE::<CI<153>> {}, CE::<CI<154>> {}, CE::<CI<155>> {});
    let (in156, in157, in158) = (CE::<CI<156>> {}, CE::<CI<157>> {}, CE::<CI<158>> {});
    let (in159, in160, in161) = (CE::<CI<159>> {}, CE::<CI<160>> {}, CE::<CI<161>> {});
    let (in162, in163, in164) = (CE::<CI<162>> {}, CE::<CI<163>> {}, CE::<CI<164>> {});
    let (in165, in166, in167) = (CE::<CI<165>> {}, CE::<CI<166>> {}, CE::<CI<167>> {});
    let (in168, in169, in170) = (CE::<CI<168>> {}, CE::<CI<169>> {}, CE::<CI<170>> {});
    let (in171, in172, in173) = (CE::<CI<171>> {}, CE::<CI<172>> {}, CE::<CI<173>> {});
    let (in174, in175, in176) = (CE::<CI<174>> {}, CE::<CI<175>> {}, CE::<CI<176>> {});
    let (in177, in178, in179) = (CE::<CI<177>> {}, CE::<CI<178>> {}, CE::<CI<179>> {});
    let (in180, in181, in182) = (CE::<CI<180>> {}, CE::<CI<181>> {}, CE::<CI<182>> {});
    let (in183, in184, in185) = (CE::<CI<183>> {}, CE::<CI<184>> {}, CE::<CI<185>> {});
    let (in186, in187, in188) = (CE::<CI<186>> {}, CE::<CI<187>> {}, CE::<CI<188>> {});
    let (in189, in190, in191) = (CE::<CI<189>> {}, CE::<CI<190>> {}, CE::<CI<191>> {});
    let (in192, in193, in194) = (CE::<CI<192>> {}, CE::<CI<193>> {}, CE::<CI<194>> {});
    let (in195, in196, in197) = (CE::<CI<195>> {}, CE::<CI<196>> {}, CE::<CI<197>> {});
    let (in198, in199, in200) = (CE::<CI<198>> {}, CE::<CI<199>> {}, CE::<CI<200>> {});
    let (in201, in202, in203) = (CE::<CI<201>> {}, CE::<CI<202>> {}, CE::<CI<203>> {});
    let t0 = circuit_mul(in53, in0); // Eval sumdlogdiv_a_num Horner step: multiply by xA0
    let t1 = circuit_add(in52, t0); // Eval sumdlogdiv_a_num Horner step: add coefficient_46
    let t2 = circuit_mul(t1, in0); // Eval sumdlogdiv_a_num Horner step: multiply by xA0
    let t3 = circuit_add(in51, t2); // Eval sumdlogdiv_a_num Horner step: add coefficient_45
    let t4 = circuit_mul(t3, in0); // Eval sumdlogdiv_a_num Horner step: multiply by xA0
    let t5 = circuit_add(in50, t4); // Eval sumdlogdiv_a_num Horner step: add coefficient_44
    let t6 = circuit_mul(t5, in0); // Eval sumdlogdiv_a_num Horner step: multiply by xA0
    let t7 = circuit_add(in49, t6); // Eval sumdlogdiv_a_num Horner step: add coefficient_43
    let t8 = circuit_mul(t7, in0); // Eval sumdlogdiv_a_num Horner step: multiply by xA0
    let t9 = circuit_add(in48, t8); // Eval sumdlogdiv_a_num Horner step: add coefficient_42
    let t10 = circuit_mul(t9, in0); // Eval sumdlogdiv_a_num Horner step: multiply by xA0
    let t11 = circuit_add(in47, t10); // Eval sumdlogdiv_a_num Horner step: add coefficient_41
    let t12 = circuit_mul(t11, in0); // Eval sumdlogdiv_a_num Horner step: multiply by xA0
    let t13 = circuit_add(in46, t12); // Eval sumdlogdiv_a_num Horner step: add coefficient_40
    let t14 = circuit_mul(t13, in0); // Eval sumdlogdiv_a_num Horner step: multiply by xA0
    let t15 = circuit_add(in45, t14); // Eval sumdlogdiv_a_num Horner step: add coefficient_39
    let t16 = circuit_mul(t15, in0); // Eval sumdlogdiv_a_num Horner step: multiply by xA0
    let t17 = circuit_add(in44, t16); // Eval sumdlogdiv_a_num Horner step: add coefficient_38
    let t18 = circuit_mul(t17, in0); // Eval sumdlogdiv_a_num Horner step: multiply by xA0
    let t19 = circuit_add(in43, t18); // Eval sumdlogdiv_a_num Horner step: add coefficient_37
    let t20 = circuit_mul(t19, in0); // Eval sumdlogdiv_a_num Horner step: multiply by xA0
    let t21 = circuit_add(in42, t20); // Eval sumdlogdiv_a_num Horner step: add coefficient_36
    let t22 = circuit_mul(t21, in0); // Eval sumdlogdiv_a_num Horner step: multiply by xA0
    let t23 = circuit_add(in41, t22); // Eval sumdlogdiv_a_num Horner step: add coefficient_35
    let t24 = circuit_mul(t23, in0); // Eval sumdlogdiv_a_num Horner step: multiply by xA0
    let t25 = circuit_add(in40, t24); // Eval sumdlogdiv_a_num Horner step: add coefficient_34
    let t26 = circuit_mul(t25, in0); // Eval sumdlogdiv_a_num Horner step: multiply by xA0
    let t27 = circuit_add(in39, t26); // Eval sumdlogdiv_a_num Horner step: add coefficient_33
    let t28 = circuit_mul(t27, in0); // Eval sumdlogdiv_a_num Horner step: multiply by xA0
    let t29 = circuit_add(in38, t28); // Eval sumdlogdiv_a_num Horner step: add coefficient_32
    let t30 = circuit_mul(t29, in0); // Eval sumdlogdiv_a_num Horner step: multiply by xA0
    let t31 = circuit_add(in37, t30); // Eval sumdlogdiv_a_num Horner step: add coefficient_31
    let t32 = circuit_mul(t31, in0); // Eval sumdlogdiv_a_num Horner step: multiply by xA0
    let t33 = circuit_add(in36, t32); // Eval sumdlogdiv_a_num Horner step: add coefficient_30
    let t34 = circuit_mul(t33, in0); // Eval sumdlogdiv_a_num Horner step: multiply by xA0
    let t35 = circuit_add(in35, t34); // Eval sumdlogdiv_a_num Horner step: add coefficient_29
    let t36 = circuit_mul(t35, in0); // Eval sumdlogdiv_a_num Horner step: multiply by xA0
    let t37 = circuit_add(in34, t36); // Eval sumdlogdiv_a_num Horner step: add coefficient_28
    let t38 = circuit_mul(t37, in0); // Eval sumdlogdiv_a_num Horner step: multiply by xA0
    let t39 = circuit_add(in33, t38); // Eval sumdlogdiv_a_num Horner step: add coefficient_27
    let t40 = circuit_mul(t39, in0); // Eval sumdlogdiv_a_num Horner step: multiply by xA0
    let t41 = circuit_add(in32, t40); // Eval sumdlogdiv_a_num Horner step: add coefficient_26
    let t42 = circuit_mul(t41, in0); // Eval sumdlogdiv_a_num Horner step: multiply by xA0
    let t43 = circuit_add(in31, t42); // Eval sumdlogdiv_a_num Horner step: add coefficient_25
    let t44 = circuit_mul(t43, in0); // Eval sumdlogdiv_a_num Horner step: multiply by xA0
    let t45 = circuit_add(in30, t44); // Eval sumdlogdiv_a_num Horner step: add coefficient_24
    let t46 = circuit_mul(t45, in0); // Eval sumdlogdiv_a_num Horner step: multiply by xA0
    let t47 = circuit_add(in29, t46); // Eval sumdlogdiv_a_num Horner step: add coefficient_23
    let t48 = circuit_mul(t47, in0); // Eval sumdlogdiv_a_num Horner step: multiply by xA0
    let t49 = circuit_add(in28, t48); // Eval sumdlogdiv_a_num Horner step: add coefficient_22
    let t50 = circuit_mul(t49, in0); // Eval sumdlogdiv_a_num Horner step: multiply by xA0
    let t51 = circuit_add(in27, t50); // Eval sumdlogdiv_a_num Horner step: add coefficient_21
    let t52 = circuit_mul(t51, in0); // Eval sumdlogdiv_a_num Horner step: multiply by xA0
    let t53 = circuit_add(in26, t52); // Eval sumdlogdiv_a_num Horner step: add coefficient_20
    let t54 = circuit_mul(t53, in0); // Eval sumdlogdiv_a_num Horner step: multiply by xA0
    let t55 = circuit_add(in25, t54); // Eval sumdlogdiv_a_num Horner step: add coefficient_19
    let t56 = circuit_mul(t55, in0); // Eval sumdlogdiv_a_num Horner step: multiply by xA0
    let t57 = circuit_add(in24, t56); // Eval sumdlogdiv_a_num Horner step: add coefficient_18
    let t58 = circuit_mul(t57, in0); // Eval sumdlogdiv_a_num Horner step: multiply by xA0
    let t59 = circuit_add(in23, t58); // Eval sumdlogdiv_a_num Horner step: add coefficient_17
    let t60 = circuit_mul(t59, in0); // Eval sumdlogdiv_a_num Horner step: multiply by xA0
    let t61 = circuit_add(in22, t60); // Eval sumdlogdiv_a_num Horner step: add coefficient_16
    let t62 = circuit_mul(t61, in0); // Eval sumdlogdiv_a_num Horner step: multiply by xA0
    let t63 = circuit_add(in21, t62); // Eval sumdlogdiv_a_num Horner step: add coefficient_15
    let t64 = circuit_mul(t63, in0); // Eval sumdlogdiv_a_num Horner step: multiply by xA0
    let t65 = circuit_add(in20, t64); // Eval sumdlogdiv_a_num Horner step: add coefficient_14
    let t66 = circuit_mul(t65, in0); // Eval sumdlogdiv_a_num Horner step: multiply by xA0
    let t67 = circuit_add(in19, t66); // Eval sumdlogdiv_a_num Horner step: add coefficient_13
    let t68 = circuit_mul(t67, in0); // Eval sumdlogdiv_a_num Horner step: multiply by xA0
    let t69 = circuit_add(in18, t68); // Eval sumdlogdiv_a_num Horner step: add coefficient_12
    let t70 = circuit_mul(t69, in0); // Eval sumdlogdiv_a_num Horner step: multiply by xA0
    let t71 = circuit_add(in17, t70); // Eval sumdlogdiv_a_num Horner step: add coefficient_11
    let t72 = circuit_mul(t71, in0); // Eval sumdlogdiv_a_num Horner step: multiply by xA0
    let t73 = circuit_add(in16, t72); // Eval sumdlogdiv_a_num Horner step: add coefficient_10
    let t74 = circuit_mul(t73, in0); // Eval sumdlogdiv_a_num Horner step: multiply by xA0
    let t75 = circuit_add(in15, t74); // Eval sumdlogdiv_a_num Horner step: add coefficient_9
    let t76 = circuit_mul(t75, in0); // Eval sumdlogdiv_a_num Horner step: multiply by xA0
    let t77 = circuit_add(in14, t76); // Eval sumdlogdiv_a_num Horner step: add coefficient_8
    let t78 = circuit_mul(t77, in0); // Eval sumdlogdiv_a_num Horner step: multiply by xA0
    let t79 = circuit_add(in13, t78); // Eval sumdlogdiv_a_num Horner step: add coefficient_7
    let t80 = circuit_mul(t79, in0); // Eval sumdlogdiv_a_num Horner step: multiply by xA0
    let t81 = circuit_add(in12, t80); // Eval sumdlogdiv_a_num Horner step: add coefficient_6
    let t82 = circuit_mul(t81, in0); // Eval sumdlogdiv_a_num Horner step: multiply by xA0
    let t83 = circuit_add(in11, t82); // Eval sumdlogdiv_a_num Horner step: add coefficient_5
    let t84 = circuit_mul(t83, in0); // Eval sumdlogdiv_a_num Horner step: multiply by xA0
    let t85 = circuit_add(in10, t84); // Eval sumdlogdiv_a_num Horner step: add coefficient_4
    let t86 = circuit_mul(t85, in0); // Eval sumdlogdiv_a_num Horner step: multiply by xA0
    let t87 = circuit_add(in9, t86); // Eval sumdlogdiv_a_num Horner step: add coefficient_3
    let t88 = circuit_mul(t87, in0); // Eval sumdlogdiv_a_num Horner step: multiply by xA0
    let t89 = circuit_add(in8, t88); // Eval sumdlogdiv_a_num Horner step: add coefficient_2
    let t90 = circuit_mul(t89, in0); // Eval sumdlogdiv_a_num Horner step: multiply by xA0
    let t91 = circuit_add(in7, t90); // Eval sumdlogdiv_a_num Horner step: add coefficient_1
    let t92 = circuit_mul(t91, in0); // Eval sumdlogdiv_a_num Horner step: multiply by xA0
    let t93 = circuit_add(in6, t92); // Eval sumdlogdiv_a_num Horner step: add coefficient_0
    let t94 = circuit_mul(in102, in0); // Eval sumdlogdiv_a_den Horner step: multiply by xA0
    let t95 = circuit_add(in101, t94); // Eval sumdlogdiv_a_den Horner step: add coefficient_47
    let t96 = circuit_mul(t95, in0); // Eval sumdlogdiv_a_den Horner step: multiply by xA0
    let t97 = circuit_add(in100, t96); // Eval sumdlogdiv_a_den Horner step: add coefficient_46
    let t98 = circuit_mul(t97, in0); // Eval sumdlogdiv_a_den Horner step: multiply by xA0
    let t99 = circuit_add(in99, t98); // Eval sumdlogdiv_a_den Horner step: add coefficient_45
    let t100 = circuit_mul(t99, in0); // Eval sumdlogdiv_a_den Horner step: multiply by xA0
    let t101 = circuit_add(in98, t100); // Eval sumdlogdiv_a_den Horner step: add coefficient_44
    let t102 = circuit_mul(t101, in0); // Eval sumdlogdiv_a_den Horner step: multiply by xA0
    let t103 = circuit_add(in97, t102); // Eval sumdlogdiv_a_den Horner step: add coefficient_43
    let t104 = circuit_mul(t103, in0); // Eval sumdlogdiv_a_den Horner step: multiply by xA0
    let t105 = circuit_add(in96, t104); // Eval sumdlogdiv_a_den Horner step: add coefficient_42
    let t106 = circuit_mul(t105, in0); // Eval sumdlogdiv_a_den Horner step: multiply by xA0
    let t107 = circuit_add(in95, t106); // Eval sumdlogdiv_a_den Horner step: add coefficient_41
    let t108 = circuit_mul(t107, in0); // Eval sumdlogdiv_a_den Horner step: multiply by xA0
    let t109 = circuit_add(in94, t108); // Eval sumdlogdiv_a_den Horner step: add coefficient_40
    let t110 = circuit_mul(t109, in0); // Eval sumdlogdiv_a_den Horner step: multiply by xA0
    let t111 = circuit_add(in93, t110); // Eval sumdlogdiv_a_den Horner step: add coefficient_39
    let t112 = circuit_mul(t111, in0); // Eval sumdlogdiv_a_den Horner step: multiply by xA0
    let t113 = circuit_add(in92, t112); // Eval sumdlogdiv_a_den Horner step: add coefficient_38
    let t114 = circuit_mul(t113, in0); // Eval sumdlogdiv_a_den Horner step: multiply by xA0
    let t115 = circuit_add(in91, t114); // Eval sumdlogdiv_a_den Horner step: add coefficient_37
    let t116 = circuit_mul(t115, in0); // Eval sumdlogdiv_a_den Horner step: multiply by xA0
    let t117 = circuit_add(in90, t116); // Eval sumdlogdiv_a_den Horner step: add coefficient_36
    let t118 = circuit_mul(t117, in0); // Eval sumdlogdiv_a_den Horner step: multiply by xA0
    let t119 = circuit_add(in89, t118); // Eval sumdlogdiv_a_den Horner step: add coefficient_35
    let t120 = circuit_mul(t119, in0); // Eval sumdlogdiv_a_den Horner step: multiply by xA0
    let t121 = circuit_add(in88, t120); // Eval sumdlogdiv_a_den Horner step: add coefficient_34
    let t122 = circuit_mul(t121, in0); // Eval sumdlogdiv_a_den Horner step: multiply by xA0
    let t123 = circuit_add(in87, t122); // Eval sumdlogdiv_a_den Horner step: add coefficient_33
    let t124 = circuit_mul(t123, in0); // Eval sumdlogdiv_a_den Horner step: multiply by xA0
    let t125 = circuit_add(in86, t124); // Eval sumdlogdiv_a_den Horner step: add coefficient_32
    let t126 = circuit_mul(t125, in0); // Eval sumdlogdiv_a_den Horner step: multiply by xA0
    let t127 = circuit_add(in85, t126); // Eval sumdlogdiv_a_den Horner step: add coefficient_31
    let t128 = circuit_mul(t127, in0); // Eval sumdlogdiv_a_den Horner step: multiply by xA0
    let t129 = circuit_add(in84, t128); // Eval sumdlogdiv_a_den Horner step: add coefficient_30
    let t130 = circuit_mul(t129, in0); // Eval sumdlogdiv_a_den Horner step: multiply by xA0
    let t131 = circuit_add(in83, t130); // Eval sumdlogdiv_a_den Horner step: add coefficient_29
    let t132 = circuit_mul(t131, in0); // Eval sumdlogdiv_a_den Horner step: multiply by xA0
    let t133 = circuit_add(in82, t132); // Eval sumdlogdiv_a_den Horner step: add coefficient_28
    let t134 = circuit_mul(t133, in0); // Eval sumdlogdiv_a_den Horner step: multiply by xA0
    let t135 = circuit_add(in81, t134); // Eval sumdlogdiv_a_den Horner step: add coefficient_27
    let t136 = circuit_mul(t135, in0); // Eval sumdlogdiv_a_den Horner step: multiply by xA0
    let t137 = circuit_add(in80, t136); // Eval sumdlogdiv_a_den Horner step: add coefficient_26
    let t138 = circuit_mul(t137, in0); // Eval sumdlogdiv_a_den Horner step: multiply by xA0
    let t139 = circuit_add(in79, t138); // Eval sumdlogdiv_a_den Horner step: add coefficient_25
    let t140 = circuit_mul(t139, in0); // Eval sumdlogdiv_a_den Horner step: multiply by xA0
    let t141 = circuit_add(in78, t140); // Eval sumdlogdiv_a_den Horner step: add coefficient_24
    let t142 = circuit_mul(t141, in0); // Eval sumdlogdiv_a_den Horner step: multiply by xA0
    let t143 = circuit_add(in77, t142); // Eval sumdlogdiv_a_den Horner step: add coefficient_23
    let t144 = circuit_mul(t143, in0); // Eval sumdlogdiv_a_den Horner step: multiply by xA0
    let t145 = circuit_add(in76, t144); // Eval sumdlogdiv_a_den Horner step: add coefficient_22
    let t146 = circuit_mul(t145, in0); // Eval sumdlogdiv_a_den Horner step: multiply by xA0
    let t147 = circuit_add(in75, t146); // Eval sumdlogdiv_a_den Horner step: add coefficient_21
    let t148 = circuit_mul(t147, in0); // Eval sumdlogdiv_a_den Horner step: multiply by xA0
    let t149 = circuit_add(in74, t148); // Eval sumdlogdiv_a_den Horner step: add coefficient_20
    let t150 = circuit_mul(t149, in0); // Eval sumdlogdiv_a_den Horner step: multiply by xA0
    let t151 = circuit_add(in73, t150); // Eval sumdlogdiv_a_den Horner step: add coefficient_19
    let t152 = circuit_mul(t151, in0); // Eval sumdlogdiv_a_den Horner step: multiply by xA0
    let t153 = circuit_add(in72, t152); // Eval sumdlogdiv_a_den Horner step: add coefficient_18
    let t154 = circuit_mul(t153, in0); // Eval sumdlogdiv_a_den Horner step: multiply by xA0
    let t155 = circuit_add(in71, t154); // Eval sumdlogdiv_a_den Horner step: add coefficient_17
    let t156 = circuit_mul(t155, in0); // Eval sumdlogdiv_a_den Horner step: multiply by xA0
    let t157 = circuit_add(in70, t156); // Eval sumdlogdiv_a_den Horner step: add coefficient_16
    let t158 = circuit_mul(t157, in0); // Eval sumdlogdiv_a_den Horner step: multiply by xA0
    let t159 = circuit_add(in69, t158); // Eval sumdlogdiv_a_den Horner step: add coefficient_15
    let t160 = circuit_mul(t159, in0); // Eval sumdlogdiv_a_den Horner step: multiply by xA0
    let t161 = circuit_add(in68, t160); // Eval sumdlogdiv_a_den Horner step: add coefficient_14
    let t162 = circuit_mul(t161, in0); // Eval sumdlogdiv_a_den Horner step: multiply by xA0
    let t163 = circuit_add(in67, t162); // Eval sumdlogdiv_a_den Horner step: add coefficient_13
    let t164 = circuit_mul(t163, in0); // Eval sumdlogdiv_a_den Horner step: multiply by xA0
    let t165 = circuit_add(in66, t164); // Eval sumdlogdiv_a_den Horner step: add coefficient_12
    let t166 = circuit_mul(t165, in0); // Eval sumdlogdiv_a_den Horner step: multiply by xA0
    let t167 = circuit_add(in65, t166); // Eval sumdlogdiv_a_den Horner step: add coefficient_11
    let t168 = circuit_mul(t167, in0); // Eval sumdlogdiv_a_den Horner step: multiply by xA0
    let t169 = circuit_add(in64, t168); // Eval sumdlogdiv_a_den Horner step: add coefficient_10
    let t170 = circuit_mul(t169, in0); // Eval sumdlogdiv_a_den Horner step: multiply by xA0
    let t171 = circuit_add(in63, t170); // Eval sumdlogdiv_a_den Horner step: add coefficient_9
    let t172 = circuit_mul(t171, in0); // Eval sumdlogdiv_a_den Horner step: multiply by xA0
    let t173 = circuit_add(in62, t172); // Eval sumdlogdiv_a_den Horner step: add coefficient_8
    let t174 = circuit_mul(t173, in0); // Eval sumdlogdiv_a_den Horner step: multiply by xA0
    let t175 = circuit_add(in61, t174); // Eval sumdlogdiv_a_den Horner step: add coefficient_7
    let t176 = circuit_mul(t175, in0); // Eval sumdlogdiv_a_den Horner step: multiply by xA0
    let t177 = circuit_add(in60, t176); // Eval sumdlogdiv_a_den Horner step: add coefficient_6
    let t178 = circuit_mul(t177, in0); // Eval sumdlogdiv_a_den Horner step: multiply by xA0
    let t179 = circuit_add(in59, t178); // Eval sumdlogdiv_a_den Horner step: add coefficient_5
    let t180 = circuit_mul(t179, in0); // Eval sumdlogdiv_a_den Horner step: multiply by xA0
    let t181 = circuit_add(in58, t180); // Eval sumdlogdiv_a_den Horner step: add coefficient_4
    let t182 = circuit_mul(t181, in0); // Eval sumdlogdiv_a_den Horner step: multiply by xA0
    let t183 = circuit_add(in57, t182); // Eval sumdlogdiv_a_den Horner step: add coefficient_3
    let t184 = circuit_mul(t183, in0); // Eval sumdlogdiv_a_den Horner step: multiply by xA0
    let t185 = circuit_add(in56, t184); // Eval sumdlogdiv_a_den Horner step: add coefficient_2
    let t186 = circuit_mul(t185, in0); // Eval sumdlogdiv_a_den Horner step: multiply by xA0
    let t187 = circuit_add(in55, t186); // Eval sumdlogdiv_a_den Horner step: add coefficient_1
    let t188 = circuit_mul(t187, in0); // Eval sumdlogdiv_a_den Horner step: multiply by xA0
    let t189 = circuit_add(in54, t188); // Eval sumdlogdiv_a_den Horner step: add coefficient_0
    let t190 = circuit_inverse(t189);
    let t191 = circuit_mul(t93, t190);
    let t192 = circuit_mul(in151, in0); // Eval sumdlogdiv_b_num Horner step: multiply by xA0
    let t193 = circuit_add(in150, t192); // Eval sumdlogdiv_b_num Horner step: add coefficient_47
    let t194 = circuit_mul(t193, in0); // Eval sumdlogdiv_b_num Horner step: multiply by xA0
    let t195 = circuit_add(in149, t194); // Eval sumdlogdiv_b_num Horner step: add coefficient_46
    let t196 = circuit_mul(t195, in0); // Eval sumdlogdiv_b_num Horner step: multiply by xA0
    let t197 = circuit_add(in148, t196); // Eval sumdlogdiv_b_num Horner step: add coefficient_45
    let t198 = circuit_mul(t197, in0); // Eval sumdlogdiv_b_num Horner step: multiply by xA0
    let t199 = circuit_add(in147, t198); // Eval sumdlogdiv_b_num Horner step: add coefficient_44
    let t200 = circuit_mul(t199, in0); // Eval sumdlogdiv_b_num Horner step: multiply by xA0
    let t201 = circuit_add(in146, t200); // Eval sumdlogdiv_b_num Horner step: add coefficient_43
    let t202 = circuit_mul(t201, in0); // Eval sumdlogdiv_b_num Horner step: multiply by xA0
    let t203 = circuit_add(in145, t202); // Eval sumdlogdiv_b_num Horner step: add coefficient_42
    let t204 = circuit_mul(t203, in0); // Eval sumdlogdiv_b_num Horner step: multiply by xA0
    let t205 = circuit_add(in144, t204); // Eval sumdlogdiv_b_num Horner step: add coefficient_41
    let t206 = circuit_mul(t205, in0); // Eval sumdlogdiv_b_num Horner step: multiply by xA0
    let t207 = circuit_add(in143, t206); // Eval sumdlogdiv_b_num Horner step: add coefficient_40
    let t208 = circuit_mul(t207, in0); // Eval sumdlogdiv_b_num Horner step: multiply by xA0
    let t209 = circuit_add(in142, t208); // Eval sumdlogdiv_b_num Horner step: add coefficient_39
    let t210 = circuit_mul(t209, in0); // Eval sumdlogdiv_b_num Horner step: multiply by xA0
    let t211 = circuit_add(in141, t210); // Eval sumdlogdiv_b_num Horner step: add coefficient_38
    let t212 = circuit_mul(t211, in0); // Eval sumdlogdiv_b_num Horner step: multiply by xA0
    let t213 = circuit_add(in140, t212); // Eval sumdlogdiv_b_num Horner step: add coefficient_37
    let t214 = circuit_mul(t213, in0); // Eval sumdlogdiv_b_num Horner step: multiply by xA0
    let t215 = circuit_add(in139, t214); // Eval sumdlogdiv_b_num Horner step: add coefficient_36
    let t216 = circuit_mul(t215, in0); // Eval sumdlogdiv_b_num Horner step: multiply by xA0
    let t217 = circuit_add(in138, t216); // Eval sumdlogdiv_b_num Horner step: add coefficient_35
    let t218 = circuit_mul(t217, in0); // Eval sumdlogdiv_b_num Horner step: multiply by xA0
    let t219 = circuit_add(in137, t218); // Eval sumdlogdiv_b_num Horner step: add coefficient_34
    let t220 = circuit_mul(t219, in0); // Eval sumdlogdiv_b_num Horner step: multiply by xA0
    let t221 = circuit_add(in136, t220); // Eval sumdlogdiv_b_num Horner step: add coefficient_33
    let t222 = circuit_mul(t221, in0); // Eval sumdlogdiv_b_num Horner step: multiply by xA0
    let t223 = circuit_add(in135, t222); // Eval sumdlogdiv_b_num Horner step: add coefficient_32
    let t224 = circuit_mul(t223, in0); // Eval sumdlogdiv_b_num Horner step: multiply by xA0
    let t225 = circuit_add(in134, t224); // Eval sumdlogdiv_b_num Horner step: add coefficient_31
    let t226 = circuit_mul(t225, in0); // Eval sumdlogdiv_b_num Horner step: multiply by xA0
    let t227 = circuit_add(in133, t226); // Eval sumdlogdiv_b_num Horner step: add coefficient_30
    let t228 = circuit_mul(t227, in0); // Eval sumdlogdiv_b_num Horner step: multiply by xA0
    let t229 = circuit_add(in132, t228); // Eval sumdlogdiv_b_num Horner step: add coefficient_29
    let t230 = circuit_mul(t229, in0); // Eval sumdlogdiv_b_num Horner step: multiply by xA0
    let t231 = circuit_add(in131, t230); // Eval sumdlogdiv_b_num Horner step: add coefficient_28
    let t232 = circuit_mul(t231, in0); // Eval sumdlogdiv_b_num Horner step: multiply by xA0
    let t233 = circuit_add(in130, t232); // Eval sumdlogdiv_b_num Horner step: add coefficient_27
    let t234 = circuit_mul(t233, in0); // Eval sumdlogdiv_b_num Horner step: multiply by xA0
    let t235 = circuit_add(in129, t234); // Eval sumdlogdiv_b_num Horner step: add coefficient_26
    let t236 = circuit_mul(t235, in0); // Eval sumdlogdiv_b_num Horner step: multiply by xA0
    let t237 = circuit_add(in128, t236); // Eval sumdlogdiv_b_num Horner step: add coefficient_25
    let t238 = circuit_mul(t237, in0); // Eval sumdlogdiv_b_num Horner step: multiply by xA0
    let t239 = circuit_add(in127, t238); // Eval sumdlogdiv_b_num Horner step: add coefficient_24
    let t240 = circuit_mul(t239, in0); // Eval sumdlogdiv_b_num Horner step: multiply by xA0
    let t241 = circuit_add(in126, t240); // Eval sumdlogdiv_b_num Horner step: add coefficient_23
    let t242 = circuit_mul(t241, in0); // Eval sumdlogdiv_b_num Horner step: multiply by xA0
    let t243 = circuit_add(in125, t242); // Eval sumdlogdiv_b_num Horner step: add coefficient_22
    let t244 = circuit_mul(t243, in0); // Eval sumdlogdiv_b_num Horner step: multiply by xA0
    let t245 = circuit_add(in124, t244); // Eval sumdlogdiv_b_num Horner step: add coefficient_21
    let t246 = circuit_mul(t245, in0); // Eval sumdlogdiv_b_num Horner step: multiply by xA0
    let t247 = circuit_add(in123, t246); // Eval sumdlogdiv_b_num Horner step: add coefficient_20
    let t248 = circuit_mul(t247, in0); // Eval sumdlogdiv_b_num Horner step: multiply by xA0
    let t249 = circuit_add(in122, t248); // Eval sumdlogdiv_b_num Horner step: add coefficient_19
    let t250 = circuit_mul(t249, in0); // Eval sumdlogdiv_b_num Horner step: multiply by xA0
    let t251 = circuit_add(in121, t250); // Eval sumdlogdiv_b_num Horner step: add coefficient_18
    let t252 = circuit_mul(t251, in0); // Eval sumdlogdiv_b_num Horner step: multiply by xA0
    let t253 = circuit_add(in120, t252); // Eval sumdlogdiv_b_num Horner step: add coefficient_17
    let t254 = circuit_mul(t253, in0); // Eval sumdlogdiv_b_num Horner step: multiply by xA0
    let t255 = circuit_add(in119, t254); // Eval sumdlogdiv_b_num Horner step: add coefficient_16
    let t256 = circuit_mul(t255, in0); // Eval sumdlogdiv_b_num Horner step: multiply by xA0
    let t257 = circuit_add(in118, t256); // Eval sumdlogdiv_b_num Horner step: add coefficient_15
    let t258 = circuit_mul(t257, in0); // Eval sumdlogdiv_b_num Horner step: multiply by xA0
    let t259 = circuit_add(in117, t258); // Eval sumdlogdiv_b_num Horner step: add coefficient_14
    let t260 = circuit_mul(t259, in0); // Eval sumdlogdiv_b_num Horner step: multiply by xA0
    let t261 = circuit_add(in116, t260); // Eval sumdlogdiv_b_num Horner step: add coefficient_13
    let t262 = circuit_mul(t261, in0); // Eval sumdlogdiv_b_num Horner step: multiply by xA0
    let t263 = circuit_add(in115, t262); // Eval sumdlogdiv_b_num Horner step: add coefficient_12
    let t264 = circuit_mul(t263, in0); // Eval sumdlogdiv_b_num Horner step: multiply by xA0
    let t265 = circuit_add(in114, t264); // Eval sumdlogdiv_b_num Horner step: add coefficient_11
    let t266 = circuit_mul(t265, in0); // Eval sumdlogdiv_b_num Horner step: multiply by xA0
    let t267 = circuit_add(in113, t266); // Eval sumdlogdiv_b_num Horner step: add coefficient_10
    let t268 = circuit_mul(t267, in0); // Eval sumdlogdiv_b_num Horner step: multiply by xA0
    let t269 = circuit_add(in112, t268); // Eval sumdlogdiv_b_num Horner step: add coefficient_9
    let t270 = circuit_mul(t269, in0); // Eval sumdlogdiv_b_num Horner step: multiply by xA0
    let t271 = circuit_add(in111, t270); // Eval sumdlogdiv_b_num Horner step: add coefficient_8
    let t272 = circuit_mul(t271, in0); // Eval sumdlogdiv_b_num Horner step: multiply by xA0
    let t273 = circuit_add(in110, t272); // Eval sumdlogdiv_b_num Horner step: add coefficient_7
    let t274 = circuit_mul(t273, in0); // Eval sumdlogdiv_b_num Horner step: multiply by xA0
    let t275 = circuit_add(in109, t274); // Eval sumdlogdiv_b_num Horner step: add coefficient_6
    let t276 = circuit_mul(t275, in0); // Eval sumdlogdiv_b_num Horner step: multiply by xA0
    let t277 = circuit_add(in108, t276); // Eval sumdlogdiv_b_num Horner step: add coefficient_5
    let t278 = circuit_mul(t277, in0); // Eval sumdlogdiv_b_num Horner step: multiply by xA0
    let t279 = circuit_add(in107, t278); // Eval sumdlogdiv_b_num Horner step: add coefficient_4
    let t280 = circuit_mul(t279, in0); // Eval sumdlogdiv_b_num Horner step: multiply by xA0
    let t281 = circuit_add(in106, t280); // Eval sumdlogdiv_b_num Horner step: add coefficient_3
    let t282 = circuit_mul(t281, in0); // Eval sumdlogdiv_b_num Horner step: multiply by xA0
    let t283 = circuit_add(in105, t282); // Eval sumdlogdiv_b_num Horner step: add coefficient_2
    let t284 = circuit_mul(t283, in0); // Eval sumdlogdiv_b_num Horner step: multiply by xA0
    let t285 = circuit_add(in104, t284); // Eval sumdlogdiv_b_num Horner step: add coefficient_1
    let t286 = circuit_mul(t285, in0); // Eval sumdlogdiv_b_num Horner step: multiply by xA0
    let t287 = circuit_add(in103, t286); // Eval sumdlogdiv_b_num Horner step: add coefficient_0
    let t288 = circuit_mul(in203, in0); // Eval sumdlogdiv_b_den Horner step: multiply by xA0
    let t289 = circuit_add(in202, t288); // Eval sumdlogdiv_b_den Horner step: add coefficient_50
    let t290 = circuit_mul(t289, in0); // Eval sumdlogdiv_b_den Horner step: multiply by xA0
    let t291 = circuit_add(in201, t290); // Eval sumdlogdiv_b_den Horner step: add coefficient_49
    let t292 = circuit_mul(t291, in0); // Eval sumdlogdiv_b_den Horner step: multiply by xA0
    let t293 = circuit_add(in200, t292); // Eval sumdlogdiv_b_den Horner step: add coefficient_48
    let t294 = circuit_mul(t293, in0); // Eval sumdlogdiv_b_den Horner step: multiply by xA0
    let t295 = circuit_add(in199, t294); // Eval sumdlogdiv_b_den Horner step: add coefficient_47
    let t296 = circuit_mul(t295, in0); // Eval sumdlogdiv_b_den Horner step: multiply by xA0
    let t297 = circuit_add(in198, t296); // Eval sumdlogdiv_b_den Horner step: add coefficient_46
    let t298 = circuit_mul(t297, in0); // Eval sumdlogdiv_b_den Horner step: multiply by xA0
    let t299 = circuit_add(in197, t298); // Eval sumdlogdiv_b_den Horner step: add coefficient_45
    let t300 = circuit_mul(t299, in0); // Eval sumdlogdiv_b_den Horner step: multiply by xA0
    let t301 = circuit_add(in196, t300); // Eval sumdlogdiv_b_den Horner step: add coefficient_44
    let t302 = circuit_mul(t301, in0); // Eval sumdlogdiv_b_den Horner step: multiply by xA0
    let t303 = circuit_add(in195, t302); // Eval sumdlogdiv_b_den Horner step: add coefficient_43
    let t304 = circuit_mul(t303, in0); // Eval sumdlogdiv_b_den Horner step: multiply by xA0
    let t305 = circuit_add(in194, t304); // Eval sumdlogdiv_b_den Horner step: add coefficient_42
    let t306 = circuit_mul(t305, in0); // Eval sumdlogdiv_b_den Horner step: multiply by xA0
    let t307 = circuit_add(in193, t306); // Eval sumdlogdiv_b_den Horner step: add coefficient_41
    let t308 = circuit_mul(t307, in0); // Eval sumdlogdiv_b_den Horner step: multiply by xA0
    let t309 = circuit_add(in192, t308); // Eval sumdlogdiv_b_den Horner step: add coefficient_40
    let t310 = circuit_mul(t309, in0); // Eval sumdlogdiv_b_den Horner step: multiply by xA0
    let t311 = circuit_add(in191, t310); // Eval sumdlogdiv_b_den Horner step: add coefficient_39
    let t312 = circuit_mul(t311, in0); // Eval sumdlogdiv_b_den Horner step: multiply by xA0
    let t313 = circuit_add(in190, t312); // Eval sumdlogdiv_b_den Horner step: add coefficient_38
    let t314 = circuit_mul(t313, in0); // Eval sumdlogdiv_b_den Horner step: multiply by xA0
    let t315 = circuit_add(in189, t314); // Eval sumdlogdiv_b_den Horner step: add coefficient_37
    let t316 = circuit_mul(t315, in0); // Eval sumdlogdiv_b_den Horner step: multiply by xA0
    let t317 = circuit_add(in188, t316); // Eval sumdlogdiv_b_den Horner step: add coefficient_36
    let t318 = circuit_mul(t317, in0); // Eval sumdlogdiv_b_den Horner step: multiply by xA0
    let t319 = circuit_add(in187, t318); // Eval sumdlogdiv_b_den Horner step: add coefficient_35
    let t320 = circuit_mul(t319, in0); // Eval sumdlogdiv_b_den Horner step: multiply by xA0
    let t321 = circuit_add(in186, t320); // Eval sumdlogdiv_b_den Horner step: add coefficient_34
    let t322 = circuit_mul(t321, in0); // Eval sumdlogdiv_b_den Horner step: multiply by xA0
    let t323 = circuit_add(in185, t322); // Eval sumdlogdiv_b_den Horner step: add coefficient_33
    let t324 = circuit_mul(t323, in0); // Eval sumdlogdiv_b_den Horner step: multiply by xA0
    let t325 = circuit_add(in184, t324); // Eval sumdlogdiv_b_den Horner step: add coefficient_32
    let t326 = circuit_mul(t325, in0); // Eval sumdlogdiv_b_den Horner step: multiply by xA0
    let t327 = circuit_add(in183, t326); // Eval sumdlogdiv_b_den Horner step: add coefficient_31
    let t328 = circuit_mul(t327, in0); // Eval sumdlogdiv_b_den Horner step: multiply by xA0
    let t329 = circuit_add(in182, t328); // Eval sumdlogdiv_b_den Horner step: add coefficient_30
    let t330 = circuit_mul(t329, in0); // Eval sumdlogdiv_b_den Horner step: multiply by xA0
    let t331 = circuit_add(in181, t330); // Eval sumdlogdiv_b_den Horner step: add coefficient_29
    let t332 = circuit_mul(t331, in0); // Eval sumdlogdiv_b_den Horner step: multiply by xA0
    let t333 = circuit_add(in180, t332); // Eval sumdlogdiv_b_den Horner step: add coefficient_28
    let t334 = circuit_mul(t333, in0); // Eval sumdlogdiv_b_den Horner step: multiply by xA0
    let t335 = circuit_add(in179, t334); // Eval sumdlogdiv_b_den Horner step: add coefficient_27
    let t336 = circuit_mul(t335, in0); // Eval sumdlogdiv_b_den Horner step: multiply by xA0
    let t337 = circuit_add(in178, t336); // Eval sumdlogdiv_b_den Horner step: add coefficient_26
    let t338 = circuit_mul(t337, in0); // Eval sumdlogdiv_b_den Horner step: multiply by xA0
    let t339 = circuit_add(in177, t338); // Eval sumdlogdiv_b_den Horner step: add coefficient_25
    let t340 = circuit_mul(t339, in0); // Eval sumdlogdiv_b_den Horner step: multiply by xA0
    let t341 = circuit_add(in176, t340); // Eval sumdlogdiv_b_den Horner step: add coefficient_24
    let t342 = circuit_mul(t341, in0); // Eval sumdlogdiv_b_den Horner step: multiply by xA0
    let t343 = circuit_add(in175, t342); // Eval sumdlogdiv_b_den Horner step: add coefficient_23
    let t344 = circuit_mul(t343, in0); // Eval sumdlogdiv_b_den Horner step: multiply by xA0
    let t345 = circuit_add(in174, t344); // Eval sumdlogdiv_b_den Horner step: add coefficient_22
    let t346 = circuit_mul(t345, in0); // Eval sumdlogdiv_b_den Horner step: multiply by xA0
    let t347 = circuit_add(in173, t346); // Eval sumdlogdiv_b_den Horner step: add coefficient_21
    let t348 = circuit_mul(t347, in0); // Eval sumdlogdiv_b_den Horner step: multiply by xA0
    let t349 = circuit_add(in172, t348); // Eval sumdlogdiv_b_den Horner step: add coefficient_20
    let t350 = circuit_mul(t349, in0); // Eval sumdlogdiv_b_den Horner step: multiply by xA0
    let t351 = circuit_add(in171, t350); // Eval sumdlogdiv_b_den Horner step: add coefficient_19
    let t352 = circuit_mul(t351, in0); // Eval sumdlogdiv_b_den Horner step: multiply by xA0
    let t353 = circuit_add(in170, t352); // Eval sumdlogdiv_b_den Horner step: add coefficient_18
    let t354 = circuit_mul(t353, in0); // Eval sumdlogdiv_b_den Horner step: multiply by xA0
    let t355 = circuit_add(in169, t354); // Eval sumdlogdiv_b_den Horner step: add coefficient_17
    let t356 = circuit_mul(t355, in0); // Eval sumdlogdiv_b_den Horner step: multiply by xA0
    let t357 = circuit_add(in168, t356); // Eval sumdlogdiv_b_den Horner step: add coefficient_16
    let t358 = circuit_mul(t357, in0); // Eval sumdlogdiv_b_den Horner step: multiply by xA0
    let t359 = circuit_add(in167, t358); // Eval sumdlogdiv_b_den Horner step: add coefficient_15
    let t360 = circuit_mul(t359, in0); // Eval sumdlogdiv_b_den Horner step: multiply by xA0
    let t361 = circuit_add(in166, t360); // Eval sumdlogdiv_b_den Horner step: add coefficient_14
    let t362 = circuit_mul(t361, in0); // Eval sumdlogdiv_b_den Horner step: multiply by xA0
    let t363 = circuit_add(in165, t362); // Eval sumdlogdiv_b_den Horner step: add coefficient_13
    let t364 = circuit_mul(t363, in0); // Eval sumdlogdiv_b_den Horner step: multiply by xA0
    let t365 = circuit_add(in164, t364); // Eval sumdlogdiv_b_den Horner step: add coefficient_12
    let t366 = circuit_mul(t365, in0); // Eval sumdlogdiv_b_den Horner step: multiply by xA0
    let t367 = circuit_add(in163, t366); // Eval sumdlogdiv_b_den Horner step: add coefficient_11
    let t368 = circuit_mul(t367, in0); // Eval sumdlogdiv_b_den Horner step: multiply by xA0
    let t369 = circuit_add(in162, t368); // Eval sumdlogdiv_b_den Horner step: add coefficient_10
    let t370 = circuit_mul(t369, in0); // Eval sumdlogdiv_b_den Horner step: multiply by xA0
    let t371 = circuit_add(in161, t370); // Eval sumdlogdiv_b_den Horner step: add coefficient_9
    let t372 = circuit_mul(t371, in0); // Eval sumdlogdiv_b_den Horner step: multiply by xA0
    let t373 = circuit_add(in160, t372); // Eval sumdlogdiv_b_den Horner step: add coefficient_8
    let t374 = circuit_mul(t373, in0); // Eval sumdlogdiv_b_den Horner step: multiply by xA0
    let t375 = circuit_add(in159, t374); // Eval sumdlogdiv_b_den Horner step: add coefficient_7
    let t376 = circuit_mul(t375, in0); // Eval sumdlogdiv_b_den Horner step: multiply by xA0
    let t377 = circuit_add(in158, t376); // Eval sumdlogdiv_b_den Horner step: add coefficient_6
    let t378 = circuit_mul(t377, in0); // Eval sumdlogdiv_b_den Horner step: multiply by xA0
    let t379 = circuit_add(in157, t378); // Eval sumdlogdiv_b_den Horner step: add coefficient_5
    let t380 = circuit_mul(t379, in0); // Eval sumdlogdiv_b_den Horner step: multiply by xA0
    let t381 = circuit_add(in156, t380); // Eval sumdlogdiv_b_den Horner step: add coefficient_4
    let t382 = circuit_mul(t381, in0); // Eval sumdlogdiv_b_den Horner step: multiply by xA0
    let t383 = circuit_add(in155, t382); // Eval sumdlogdiv_b_den Horner step: add coefficient_3
    let t384 = circuit_mul(t383, in0); // Eval sumdlogdiv_b_den Horner step: multiply by xA0
    let t385 = circuit_add(in154, t384); // Eval sumdlogdiv_b_den Horner step: add coefficient_2
    let t386 = circuit_mul(t385, in0); // Eval sumdlogdiv_b_den Horner step: multiply by xA0
    let t387 = circuit_add(in153, t386); // Eval sumdlogdiv_b_den Horner step: add coefficient_1
    let t388 = circuit_mul(t387, in0); // Eval sumdlogdiv_b_den Horner step: multiply by xA0
    let t389 = circuit_add(in152, t388); // Eval sumdlogdiv_b_den Horner step: add coefficient_0
    let t390 = circuit_inverse(t389);
    let t391 = circuit_mul(t287, t390);
    let t392 = circuit_mul(in1, t391);
    let t393 = circuit_add(t191, t392);
    let t394 = circuit_mul(in53, in2); // Eval sumdlogdiv_a_num Horner step: multiply by xA2
    let t395 = circuit_add(in52, t394); // Eval sumdlogdiv_a_num Horner step: add coefficient_46
    let t396 = circuit_mul(t395, in2); // Eval sumdlogdiv_a_num Horner step: multiply by xA2
    let t397 = circuit_add(in51, t396); // Eval sumdlogdiv_a_num Horner step: add coefficient_45
    let t398 = circuit_mul(t397, in2); // Eval sumdlogdiv_a_num Horner step: multiply by xA2
    let t399 = circuit_add(in50, t398); // Eval sumdlogdiv_a_num Horner step: add coefficient_44
    let t400 = circuit_mul(t399, in2); // Eval sumdlogdiv_a_num Horner step: multiply by xA2
    let t401 = circuit_add(in49, t400); // Eval sumdlogdiv_a_num Horner step: add coefficient_43
    let t402 = circuit_mul(t401, in2); // Eval sumdlogdiv_a_num Horner step: multiply by xA2
    let t403 = circuit_add(in48, t402); // Eval sumdlogdiv_a_num Horner step: add coefficient_42
    let t404 = circuit_mul(t403, in2); // Eval sumdlogdiv_a_num Horner step: multiply by xA2
    let t405 = circuit_add(in47, t404); // Eval sumdlogdiv_a_num Horner step: add coefficient_41
    let t406 = circuit_mul(t405, in2); // Eval sumdlogdiv_a_num Horner step: multiply by xA2
    let t407 = circuit_add(in46, t406); // Eval sumdlogdiv_a_num Horner step: add coefficient_40
    let t408 = circuit_mul(t407, in2); // Eval sumdlogdiv_a_num Horner step: multiply by xA2
    let t409 = circuit_add(in45, t408); // Eval sumdlogdiv_a_num Horner step: add coefficient_39
    let t410 = circuit_mul(t409, in2); // Eval sumdlogdiv_a_num Horner step: multiply by xA2
    let t411 = circuit_add(in44, t410); // Eval sumdlogdiv_a_num Horner step: add coefficient_38
    let t412 = circuit_mul(t411, in2); // Eval sumdlogdiv_a_num Horner step: multiply by xA2
    let t413 = circuit_add(in43, t412); // Eval sumdlogdiv_a_num Horner step: add coefficient_37
    let t414 = circuit_mul(t413, in2); // Eval sumdlogdiv_a_num Horner step: multiply by xA2
    let t415 = circuit_add(in42, t414); // Eval sumdlogdiv_a_num Horner step: add coefficient_36
    let t416 = circuit_mul(t415, in2); // Eval sumdlogdiv_a_num Horner step: multiply by xA2
    let t417 = circuit_add(in41, t416); // Eval sumdlogdiv_a_num Horner step: add coefficient_35
    let t418 = circuit_mul(t417, in2); // Eval sumdlogdiv_a_num Horner step: multiply by xA2
    let t419 = circuit_add(in40, t418); // Eval sumdlogdiv_a_num Horner step: add coefficient_34
    let t420 = circuit_mul(t419, in2); // Eval sumdlogdiv_a_num Horner step: multiply by xA2
    let t421 = circuit_add(in39, t420); // Eval sumdlogdiv_a_num Horner step: add coefficient_33
    let t422 = circuit_mul(t421, in2); // Eval sumdlogdiv_a_num Horner step: multiply by xA2
    let t423 = circuit_add(in38, t422); // Eval sumdlogdiv_a_num Horner step: add coefficient_32
    let t424 = circuit_mul(t423, in2); // Eval sumdlogdiv_a_num Horner step: multiply by xA2
    let t425 = circuit_add(in37, t424); // Eval sumdlogdiv_a_num Horner step: add coefficient_31
    let t426 = circuit_mul(t425, in2); // Eval sumdlogdiv_a_num Horner step: multiply by xA2
    let t427 = circuit_add(in36, t426); // Eval sumdlogdiv_a_num Horner step: add coefficient_30
    let t428 = circuit_mul(t427, in2); // Eval sumdlogdiv_a_num Horner step: multiply by xA2
    let t429 = circuit_add(in35, t428); // Eval sumdlogdiv_a_num Horner step: add coefficient_29
    let t430 = circuit_mul(t429, in2); // Eval sumdlogdiv_a_num Horner step: multiply by xA2
    let t431 = circuit_add(in34, t430); // Eval sumdlogdiv_a_num Horner step: add coefficient_28
    let t432 = circuit_mul(t431, in2); // Eval sumdlogdiv_a_num Horner step: multiply by xA2
    let t433 = circuit_add(in33, t432); // Eval sumdlogdiv_a_num Horner step: add coefficient_27
    let t434 = circuit_mul(t433, in2); // Eval sumdlogdiv_a_num Horner step: multiply by xA2
    let t435 = circuit_add(in32, t434); // Eval sumdlogdiv_a_num Horner step: add coefficient_26
    let t436 = circuit_mul(t435, in2); // Eval sumdlogdiv_a_num Horner step: multiply by xA2
    let t437 = circuit_add(in31, t436); // Eval sumdlogdiv_a_num Horner step: add coefficient_25
    let t438 = circuit_mul(t437, in2); // Eval sumdlogdiv_a_num Horner step: multiply by xA2
    let t439 = circuit_add(in30, t438); // Eval sumdlogdiv_a_num Horner step: add coefficient_24
    let t440 = circuit_mul(t439, in2); // Eval sumdlogdiv_a_num Horner step: multiply by xA2
    let t441 = circuit_add(in29, t440); // Eval sumdlogdiv_a_num Horner step: add coefficient_23
    let t442 = circuit_mul(t441, in2); // Eval sumdlogdiv_a_num Horner step: multiply by xA2
    let t443 = circuit_add(in28, t442); // Eval sumdlogdiv_a_num Horner step: add coefficient_22
    let t444 = circuit_mul(t443, in2); // Eval sumdlogdiv_a_num Horner step: multiply by xA2
    let t445 = circuit_add(in27, t444); // Eval sumdlogdiv_a_num Horner step: add coefficient_21
    let t446 = circuit_mul(t445, in2); // Eval sumdlogdiv_a_num Horner step: multiply by xA2
    let t447 = circuit_add(in26, t446); // Eval sumdlogdiv_a_num Horner step: add coefficient_20
    let t448 = circuit_mul(t447, in2); // Eval sumdlogdiv_a_num Horner step: multiply by xA2
    let t449 = circuit_add(in25, t448); // Eval sumdlogdiv_a_num Horner step: add coefficient_19
    let t450 = circuit_mul(t449, in2); // Eval sumdlogdiv_a_num Horner step: multiply by xA2
    let t451 = circuit_add(in24, t450); // Eval sumdlogdiv_a_num Horner step: add coefficient_18
    let t452 = circuit_mul(t451, in2); // Eval sumdlogdiv_a_num Horner step: multiply by xA2
    let t453 = circuit_add(in23, t452); // Eval sumdlogdiv_a_num Horner step: add coefficient_17
    let t454 = circuit_mul(t453, in2); // Eval sumdlogdiv_a_num Horner step: multiply by xA2
    let t455 = circuit_add(in22, t454); // Eval sumdlogdiv_a_num Horner step: add coefficient_16
    let t456 = circuit_mul(t455, in2); // Eval sumdlogdiv_a_num Horner step: multiply by xA2
    let t457 = circuit_add(in21, t456); // Eval sumdlogdiv_a_num Horner step: add coefficient_15
    let t458 = circuit_mul(t457, in2); // Eval sumdlogdiv_a_num Horner step: multiply by xA2
    let t459 = circuit_add(in20, t458); // Eval sumdlogdiv_a_num Horner step: add coefficient_14
    let t460 = circuit_mul(t459, in2); // Eval sumdlogdiv_a_num Horner step: multiply by xA2
    let t461 = circuit_add(in19, t460); // Eval sumdlogdiv_a_num Horner step: add coefficient_13
    let t462 = circuit_mul(t461, in2); // Eval sumdlogdiv_a_num Horner step: multiply by xA2
    let t463 = circuit_add(in18, t462); // Eval sumdlogdiv_a_num Horner step: add coefficient_12
    let t464 = circuit_mul(t463, in2); // Eval sumdlogdiv_a_num Horner step: multiply by xA2
    let t465 = circuit_add(in17, t464); // Eval sumdlogdiv_a_num Horner step: add coefficient_11
    let t466 = circuit_mul(t465, in2); // Eval sumdlogdiv_a_num Horner step: multiply by xA2
    let t467 = circuit_add(in16, t466); // Eval sumdlogdiv_a_num Horner step: add coefficient_10
    let t468 = circuit_mul(t467, in2); // Eval sumdlogdiv_a_num Horner step: multiply by xA2
    let t469 = circuit_add(in15, t468); // Eval sumdlogdiv_a_num Horner step: add coefficient_9
    let t470 = circuit_mul(t469, in2); // Eval sumdlogdiv_a_num Horner step: multiply by xA2
    let t471 = circuit_add(in14, t470); // Eval sumdlogdiv_a_num Horner step: add coefficient_8
    let t472 = circuit_mul(t471, in2); // Eval sumdlogdiv_a_num Horner step: multiply by xA2
    let t473 = circuit_add(in13, t472); // Eval sumdlogdiv_a_num Horner step: add coefficient_7
    let t474 = circuit_mul(t473, in2); // Eval sumdlogdiv_a_num Horner step: multiply by xA2
    let t475 = circuit_add(in12, t474); // Eval sumdlogdiv_a_num Horner step: add coefficient_6
    let t476 = circuit_mul(t475, in2); // Eval sumdlogdiv_a_num Horner step: multiply by xA2
    let t477 = circuit_add(in11, t476); // Eval sumdlogdiv_a_num Horner step: add coefficient_5
    let t478 = circuit_mul(t477, in2); // Eval sumdlogdiv_a_num Horner step: multiply by xA2
    let t479 = circuit_add(in10, t478); // Eval sumdlogdiv_a_num Horner step: add coefficient_4
    let t480 = circuit_mul(t479, in2); // Eval sumdlogdiv_a_num Horner step: multiply by xA2
    let t481 = circuit_add(in9, t480); // Eval sumdlogdiv_a_num Horner step: add coefficient_3
    let t482 = circuit_mul(t481, in2); // Eval sumdlogdiv_a_num Horner step: multiply by xA2
    let t483 = circuit_add(in8, t482); // Eval sumdlogdiv_a_num Horner step: add coefficient_2
    let t484 = circuit_mul(t483, in2); // Eval sumdlogdiv_a_num Horner step: multiply by xA2
    let t485 = circuit_add(in7, t484); // Eval sumdlogdiv_a_num Horner step: add coefficient_1
    let t486 = circuit_mul(t485, in2); // Eval sumdlogdiv_a_num Horner step: multiply by xA2
    let t487 = circuit_add(in6, t486); // Eval sumdlogdiv_a_num Horner step: add coefficient_0
    let t488 = circuit_mul(in102, in2); // Eval sumdlogdiv_a_den Horner step: multiply by xA2
    let t489 = circuit_add(in101, t488); // Eval sumdlogdiv_a_den Horner step: add coefficient_47
    let t490 = circuit_mul(t489, in2); // Eval sumdlogdiv_a_den Horner step: multiply by xA2
    let t491 = circuit_add(in100, t490); // Eval sumdlogdiv_a_den Horner step: add coefficient_46
    let t492 = circuit_mul(t491, in2); // Eval sumdlogdiv_a_den Horner step: multiply by xA2
    let t493 = circuit_add(in99, t492); // Eval sumdlogdiv_a_den Horner step: add coefficient_45
    let t494 = circuit_mul(t493, in2); // Eval sumdlogdiv_a_den Horner step: multiply by xA2
    let t495 = circuit_add(in98, t494); // Eval sumdlogdiv_a_den Horner step: add coefficient_44
    let t496 = circuit_mul(t495, in2); // Eval sumdlogdiv_a_den Horner step: multiply by xA2
    let t497 = circuit_add(in97, t496); // Eval sumdlogdiv_a_den Horner step: add coefficient_43
    let t498 = circuit_mul(t497, in2); // Eval sumdlogdiv_a_den Horner step: multiply by xA2
    let t499 = circuit_add(in96, t498); // Eval sumdlogdiv_a_den Horner step: add coefficient_42
    let t500 = circuit_mul(t499, in2); // Eval sumdlogdiv_a_den Horner step: multiply by xA2
    let t501 = circuit_add(in95, t500); // Eval sumdlogdiv_a_den Horner step: add coefficient_41
    let t502 = circuit_mul(t501, in2); // Eval sumdlogdiv_a_den Horner step: multiply by xA2
    let t503 = circuit_add(in94, t502); // Eval sumdlogdiv_a_den Horner step: add coefficient_40
    let t504 = circuit_mul(t503, in2); // Eval sumdlogdiv_a_den Horner step: multiply by xA2
    let t505 = circuit_add(in93, t504); // Eval sumdlogdiv_a_den Horner step: add coefficient_39
    let t506 = circuit_mul(t505, in2); // Eval sumdlogdiv_a_den Horner step: multiply by xA2
    let t507 = circuit_add(in92, t506); // Eval sumdlogdiv_a_den Horner step: add coefficient_38
    let t508 = circuit_mul(t507, in2); // Eval sumdlogdiv_a_den Horner step: multiply by xA2
    let t509 = circuit_add(in91, t508); // Eval sumdlogdiv_a_den Horner step: add coefficient_37
    let t510 = circuit_mul(t509, in2); // Eval sumdlogdiv_a_den Horner step: multiply by xA2
    let t511 = circuit_add(in90, t510); // Eval sumdlogdiv_a_den Horner step: add coefficient_36
    let t512 = circuit_mul(t511, in2); // Eval sumdlogdiv_a_den Horner step: multiply by xA2
    let t513 = circuit_add(in89, t512); // Eval sumdlogdiv_a_den Horner step: add coefficient_35
    let t514 = circuit_mul(t513, in2); // Eval sumdlogdiv_a_den Horner step: multiply by xA2
    let t515 = circuit_add(in88, t514); // Eval sumdlogdiv_a_den Horner step: add coefficient_34
    let t516 = circuit_mul(t515, in2); // Eval sumdlogdiv_a_den Horner step: multiply by xA2
    let t517 = circuit_add(in87, t516); // Eval sumdlogdiv_a_den Horner step: add coefficient_33
    let t518 = circuit_mul(t517, in2); // Eval sumdlogdiv_a_den Horner step: multiply by xA2
    let t519 = circuit_add(in86, t518); // Eval sumdlogdiv_a_den Horner step: add coefficient_32
    let t520 = circuit_mul(t519, in2); // Eval sumdlogdiv_a_den Horner step: multiply by xA2
    let t521 = circuit_add(in85, t520); // Eval sumdlogdiv_a_den Horner step: add coefficient_31
    let t522 = circuit_mul(t521, in2); // Eval sumdlogdiv_a_den Horner step: multiply by xA2
    let t523 = circuit_add(in84, t522); // Eval sumdlogdiv_a_den Horner step: add coefficient_30
    let t524 = circuit_mul(t523, in2); // Eval sumdlogdiv_a_den Horner step: multiply by xA2
    let t525 = circuit_add(in83, t524); // Eval sumdlogdiv_a_den Horner step: add coefficient_29
    let t526 = circuit_mul(t525, in2); // Eval sumdlogdiv_a_den Horner step: multiply by xA2
    let t527 = circuit_add(in82, t526); // Eval sumdlogdiv_a_den Horner step: add coefficient_28
    let t528 = circuit_mul(t527, in2); // Eval sumdlogdiv_a_den Horner step: multiply by xA2
    let t529 = circuit_add(in81, t528); // Eval sumdlogdiv_a_den Horner step: add coefficient_27
    let t530 = circuit_mul(t529, in2); // Eval sumdlogdiv_a_den Horner step: multiply by xA2
    let t531 = circuit_add(in80, t530); // Eval sumdlogdiv_a_den Horner step: add coefficient_26
    let t532 = circuit_mul(t531, in2); // Eval sumdlogdiv_a_den Horner step: multiply by xA2
    let t533 = circuit_add(in79, t532); // Eval sumdlogdiv_a_den Horner step: add coefficient_25
    let t534 = circuit_mul(t533, in2); // Eval sumdlogdiv_a_den Horner step: multiply by xA2
    let t535 = circuit_add(in78, t534); // Eval sumdlogdiv_a_den Horner step: add coefficient_24
    let t536 = circuit_mul(t535, in2); // Eval sumdlogdiv_a_den Horner step: multiply by xA2
    let t537 = circuit_add(in77, t536); // Eval sumdlogdiv_a_den Horner step: add coefficient_23
    let t538 = circuit_mul(t537, in2); // Eval sumdlogdiv_a_den Horner step: multiply by xA2
    let t539 = circuit_add(in76, t538); // Eval sumdlogdiv_a_den Horner step: add coefficient_22
    let t540 = circuit_mul(t539, in2); // Eval sumdlogdiv_a_den Horner step: multiply by xA2
    let t541 = circuit_add(in75, t540); // Eval sumdlogdiv_a_den Horner step: add coefficient_21
    let t542 = circuit_mul(t541, in2); // Eval sumdlogdiv_a_den Horner step: multiply by xA2
    let t543 = circuit_add(in74, t542); // Eval sumdlogdiv_a_den Horner step: add coefficient_20
    let t544 = circuit_mul(t543, in2); // Eval sumdlogdiv_a_den Horner step: multiply by xA2
    let t545 = circuit_add(in73, t544); // Eval sumdlogdiv_a_den Horner step: add coefficient_19
    let t546 = circuit_mul(t545, in2); // Eval sumdlogdiv_a_den Horner step: multiply by xA2
    let t547 = circuit_add(in72, t546); // Eval sumdlogdiv_a_den Horner step: add coefficient_18
    let t548 = circuit_mul(t547, in2); // Eval sumdlogdiv_a_den Horner step: multiply by xA2
    let t549 = circuit_add(in71, t548); // Eval sumdlogdiv_a_den Horner step: add coefficient_17
    let t550 = circuit_mul(t549, in2); // Eval sumdlogdiv_a_den Horner step: multiply by xA2
    let t551 = circuit_add(in70, t550); // Eval sumdlogdiv_a_den Horner step: add coefficient_16
    let t552 = circuit_mul(t551, in2); // Eval sumdlogdiv_a_den Horner step: multiply by xA2
    let t553 = circuit_add(in69, t552); // Eval sumdlogdiv_a_den Horner step: add coefficient_15
    let t554 = circuit_mul(t553, in2); // Eval sumdlogdiv_a_den Horner step: multiply by xA2
    let t555 = circuit_add(in68, t554); // Eval sumdlogdiv_a_den Horner step: add coefficient_14
    let t556 = circuit_mul(t555, in2); // Eval sumdlogdiv_a_den Horner step: multiply by xA2
    let t557 = circuit_add(in67, t556); // Eval sumdlogdiv_a_den Horner step: add coefficient_13
    let t558 = circuit_mul(t557, in2); // Eval sumdlogdiv_a_den Horner step: multiply by xA2
    let t559 = circuit_add(in66, t558); // Eval sumdlogdiv_a_den Horner step: add coefficient_12
    let t560 = circuit_mul(t559, in2); // Eval sumdlogdiv_a_den Horner step: multiply by xA2
    let t561 = circuit_add(in65, t560); // Eval sumdlogdiv_a_den Horner step: add coefficient_11
    let t562 = circuit_mul(t561, in2); // Eval sumdlogdiv_a_den Horner step: multiply by xA2
    let t563 = circuit_add(in64, t562); // Eval sumdlogdiv_a_den Horner step: add coefficient_10
    let t564 = circuit_mul(t563, in2); // Eval sumdlogdiv_a_den Horner step: multiply by xA2
    let t565 = circuit_add(in63, t564); // Eval sumdlogdiv_a_den Horner step: add coefficient_9
    let t566 = circuit_mul(t565, in2); // Eval sumdlogdiv_a_den Horner step: multiply by xA2
    let t567 = circuit_add(in62, t566); // Eval sumdlogdiv_a_den Horner step: add coefficient_8
    let t568 = circuit_mul(t567, in2); // Eval sumdlogdiv_a_den Horner step: multiply by xA2
    let t569 = circuit_add(in61, t568); // Eval sumdlogdiv_a_den Horner step: add coefficient_7
    let t570 = circuit_mul(t569, in2); // Eval sumdlogdiv_a_den Horner step: multiply by xA2
    let t571 = circuit_add(in60, t570); // Eval sumdlogdiv_a_den Horner step: add coefficient_6
    let t572 = circuit_mul(t571, in2); // Eval sumdlogdiv_a_den Horner step: multiply by xA2
    let t573 = circuit_add(in59, t572); // Eval sumdlogdiv_a_den Horner step: add coefficient_5
    let t574 = circuit_mul(t573, in2); // Eval sumdlogdiv_a_den Horner step: multiply by xA2
    let t575 = circuit_add(in58, t574); // Eval sumdlogdiv_a_den Horner step: add coefficient_4
    let t576 = circuit_mul(t575, in2); // Eval sumdlogdiv_a_den Horner step: multiply by xA2
    let t577 = circuit_add(in57, t576); // Eval sumdlogdiv_a_den Horner step: add coefficient_3
    let t578 = circuit_mul(t577, in2); // Eval sumdlogdiv_a_den Horner step: multiply by xA2
    let t579 = circuit_add(in56, t578); // Eval sumdlogdiv_a_den Horner step: add coefficient_2
    let t580 = circuit_mul(t579, in2); // Eval sumdlogdiv_a_den Horner step: multiply by xA2
    let t581 = circuit_add(in55, t580); // Eval sumdlogdiv_a_den Horner step: add coefficient_1
    let t582 = circuit_mul(t581, in2); // Eval sumdlogdiv_a_den Horner step: multiply by xA2
    let t583 = circuit_add(in54, t582); // Eval sumdlogdiv_a_den Horner step: add coefficient_0
    let t584 = circuit_inverse(t583);
    let t585 = circuit_mul(t487, t584);
    let t586 = circuit_mul(in151, in2); // Eval sumdlogdiv_b_num Horner step: multiply by xA2
    let t587 = circuit_add(in150, t586); // Eval sumdlogdiv_b_num Horner step: add coefficient_47
    let t588 = circuit_mul(t587, in2); // Eval sumdlogdiv_b_num Horner step: multiply by xA2
    let t589 = circuit_add(in149, t588); // Eval sumdlogdiv_b_num Horner step: add coefficient_46
    let t590 = circuit_mul(t589, in2); // Eval sumdlogdiv_b_num Horner step: multiply by xA2
    let t591 = circuit_add(in148, t590); // Eval sumdlogdiv_b_num Horner step: add coefficient_45
    let t592 = circuit_mul(t591, in2); // Eval sumdlogdiv_b_num Horner step: multiply by xA2
    let t593 = circuit_add(in147, t592); // Eval sumdlogdiv_b_num Horner step: add coefficient_44
    let t594 = circuit_mul(t593, in2); // Eval sumdlogdiv_b_num Horner step: multiply by xA2
    let t595 = circuit_add(in146, t594); // Eval sumdlogdiv_b_num Horner step: add coefficient_43
    let t596 = circuit_mul(t595, in2); // Eval sumdlogdiv_b_num Horner step: multiply by xA2
    let t597 = circuit_add(in145, t596); // Eval sumdlogdiv_b_num Horner step: add coefficient_42
    let t598 = circuit_mul(t597, in2); // Eval sumdlogdiv_b_num Horner step: multiply by xA2
    let t599 = circuit_add(in144, t598); // Eval sumdlogdiv_b_num Horner step: add coefficient_41
    let t600 = circuit_mul(t599, in2); // Eval sumdlogdiv_b_num Horner step: multiply by xA2
    let t601 = circuit_add(in143, t600); // Eval sumdlogdiv_b_num Horner step: add coefficient_40
    let t602 = circuit_mul(t601, in2); // Eval sumdlogdiv_b_num Horner step: multiply by xA2
    let t603 = circuit_add(in142, t602); // Eval sumdlogdiv_b_num Horner step: add coefficient_39
    let t604 = circuit_mul(t603, in2); // Eval sumdlogdiv_b_num Horner step: multiply by xA2
    let t605 = circuit_add(in141, t604); // Eval sumdlogdiv_b_num Horner step: add coefficient_38
    let t606 = circuit_mul(t605, in2); // Eval sumdlogdiv_b_num Horner step: multiply by xA2
    let t607 = circuit_add(in140, t606); // Eval sumdlogdiv_b_num Horner step: add coefficient_37
    let t608 = circuit_mul(t607, in2); // Eval sumdlogdiv_b_num Horner step: multiply by xA2
    let t609 = circuit_add(in139, t608); // Eval sumdlogdiv_b_num Horner step: add coefficient_36
    let t610 = circuit_mul(t609, in2); // Eval sumdlogdiv_b_num Horner step: multiply by xA2
    let t611 = circuit_add(in138, t610); // Eval sumdlogdiv_b_num Horner step: add coefficient_35
    let t612 = circuit_mul(t611, in2); // Eval sumdlogdiv_b_num Horner step: multiply by xA2
    let t613 = circuit_add(in137, t612); // Eval sumdlogdiv_b_num Horner step: add coefficient_34
    let t614 = circuit_mul(t613, in2); // Eval sumdlogdiv_b_num Horner step: multiply by xA2
    let t615 = circuit_add(in136, t614); // Eval sumdlogdiv_b_num Horner step: add coefficient_33
    let t616 = circuit_mul(t615, in2); // Eval sumdlogdiv_b_num Horner step: multiply by xA2
    let t617 = circuit_add(in135, t616); // Eval sumdlogdiv_b_num Horner step: add coefficient_32
    let t618 = circuit_mul(t617, in2); // Eval sumdlogdiv_b_num Horner step: multiply by xA2
    let t619 = circuit_add(in134, t618); // Eval sumdlogdiv_b_num Horner step: add coefficient_31
    let t620 = circuit_mul(t619, in2); // Eval sumdlogdiv_b_num Horner step: multiply by xA2
    let t621 = circuit_add(in133, t620); // Eval sumdlogdiv_b_num Horner step: add coefficient_30
    let t622 = circuit_mul(t621, in2); // Eval sumdlogdiv_b_num Horner step: multiply by xA2
    let t623 = circuit_add(in132, t622); // Eval sumdlogdiv_b_num Horner step: add coefficient_29
    let t624 = circuit_mul(t623, in2); // Eval sumdlogdiv_b_num Horner step: multiply by xA2
    let t625 = circuit_add(in131, t624); // Eval sumdlogdiv_b_num Horner step: add coefficient_28
    let t626 = circuit_mul(t625, in2); // Eval sumdlogdiv_b_num Horner step: multiply by xA2
    let t627 = circuit_add(in130, t626); // Eval sumdlogdiv_b_num Horner step: add coefficient_27
    let t628 = circuit_mul(t627, in2); // Eval sumdlogdiv_b_num Horner step: multiply by xA2
    let t629 = circuit_add(in129, t628); // Eval sumdlogdiv_b_num Horner step: add coefficient_26
    let t630 = circuit_mul(t629, in2); // Eval sumdlogdiv_b_num Horner step: multiply by xA2
    let t631 = circuit_add(in128, t630); // Eval sumdlogdiv_b_num Horner step: add coefficient_25
    let t632 = circuit_mul(t631, in2); // Eval sumdlogdiv_b_num Horner step: multiply by xA2
    let t633 = circuit_add(in127, t632); // Eval sumdlogdiv_b_num Horner step: add coefficient_24
    let t634 = circuit_mul(t633, in2); // Eval sumdlogdiv_b_num Horner step: multiply by xA2
    let t635 = circuit_add(in126, t634); // Eval sumdlogdiv_b_num Horner step: add coefficient_23
    let t636 = circuit_mul(t635, in2); // Eval sumdlogdiv_b_num Horner step: multiply by xA2
    let t637 = circuit_add(in125, t636); // Eval sumdlogdiv_b_num Horner step: add coefficient_22
    let t638 = circuit_mul(t637, in2); // Eval sumdlogdiv_b_num Horner step: multiply by xA2
    let t639 = circuit_add(in124, t638); // Eval sumdlogdiv_b_num Horner step: add coefficient_21
    let t640 = circuit_mul(t639, in2); // Eval sumdlogdiv_b_num Horner step: multiply by xA2
    let t641 = circuit_add(in123, t640); // Eval sumdlogdiv_b_num Horner step: add coefficient_20
    let t642 = circuit_mul(t641, in2); // Eval sumdlogdiv_b_num Horner step: multiply by xA2
    let t643 = circuit_add(in122, t642); // Eval sumdlogdiv_b_num Horner step: add coefficient_19
    let t644 = circuit_mul(t643, in2); // Eval sumdlogdiv_b_num Horner step: multiply by xA2
    let t645 = circuit_add(in121, t644); // Eval sumdlogdiv_b_num Horner step: add coefficient_18
    let t646 = circuit_mul(t645, in2); // Eval sumdlogdiv_b_num Horner step: multiply by xA2
    let t647 = circuit_add(in120, t646); // Eval sumdlogdiv_b_num Horner step: add coefficient_17
    let t648 = circuit_mul(t647, in2); // Eval sumdlogdiv_b_num Horner step: multiply by xA2
    let t649 = circuit_add(in119, t648); // Eval sumdlogdiv_b_num Horner step: add coefficient_16
    let t650 = circuit_mul(t649, in2); // Eval sumdlogdiv_b_num Horner step: multiply by xA2
    let t651 = circuit_add(in118, t650); // Eval sumdlogdiv_b_num Horner step: add coefficient_15
    let t652 = circuit_mul(t651, in2); // Eval sumdlogdiv_b_num Horner step: multiply by xA2
    let t653 = circuit_add(in117, t652); // Eval sumdlogdiv_b_num Horner step: add coefficient_14
    let t654 = circuit_mul(t653, in2); // Eval sumdlogdiv_b_num Horner step: multiply by xA2
    let t655 = circuit_add(in116, t654); // Eval sumdlogdiv_b_num Horner step: add coefficient_13
    let t656 = circuit_mul(t655, in2); // Eval sumdlogdiv_b_num Horner step: multiply by xA2
    let t657 = circuit_add(in115, t656); // Eval sumdlogdiv_b_num Horner step: add coefficient_12
    let t658 = circuit_mul(t657, in2); // Eval sumdlogdiv_b_num Horner step: multiply by xA2
    let t659 = circuit_add(in114, t658); // Eval sumdlogdiv_b_num Horner step: add coefficient_11
    let t660 = circuit_mul(t659, in2); // Eval sumdlogdiv_b_num Horner step: multiply by xA2
    let t661 = circuit_add(in113, t660); // Eval sumdlogdiv_b_num Horner step: add coefficient_10
    let t662 = circuit_mul(t661, in2); // Eval sumdlogdiv_b_num Horner step: multiply by xA2
    let t663 = circuit_add(in112, t662); // Eval sumdlogdiv_b_num Horner step: add coefficient_9
    let t664 = circuit_mul(t663, in2); // Eval sumdlogdiv_b_num Horner step: multiply by xA2
    let t665 = circuit_add(in111, t664); // Eval sumdlogdiv_b_num Horner step: add coefficient_8
    let t666 = circuit_mul(t665, in2); // Eval sumdlogdiv_b_num Horner step: multiply by xA2
    let t667 = circuit_add(in110, t666); // Eval sumdlogdiv_b_num Horner step: add coefficient_7
    let t668 = circuit_mul(t667, in2); // Eval sumdlogdiv_b_num Horner step: multiply by xA2
    let t669 = circuit_add(in109, t668); // Eval sumdlogdiv_b_num Horner step: add coefficient_6
    let t670 = circuit_mul(t669, in2); // Eval sumdlogdiv_b_num Horner step: multiply by xA2
    let t671 = circuit_add(in108, t670); // Eval sumdlogdiv_b_num Horner step: add coefficient_5
    let t672 = circuit_mul(t671, in2); // Eval sumdlogdiv_b_num Horner step: multiply by xA2
    let t673 = circuit_add(in107, t672); // Eval sumdlogdiv_b_num Horner step: add coefficient_4
    let t674 = circuit_mul(t673, in2); // Eval sumdlogdiv_b_num Horner step: multiply by xA2
    let t675 = circuit_add(in106, t674); // Eval sumdlogdiv_b_num Horner step: add coefficient_3
    let t676 = circuit_mul(t675, in2); // Eval sumdlogdiv_b_num Horner step: multiply by xA2
    let t677 = circuit_add(in105, t676); // Eval sumdlogdiv_b_num Horner step: add coefficient_2
    let t678 = circuit_mul(t677, in2); // Eval sumdlogdiv_b_num Horner step: multiply by xA2
    let t679 = circuit_add(in104, t678); // Eval sumdlogdiv_b_num Horner step: add coefficient_1
    let t680 = circuit_mul(t679, in2); // Eval sumdlogdiv_b_num Horner step: multiply by xA2
    let t681 = circuit_add(in103, t680); // Eval sumdlogdiv_b_num Horner step: add coefficient_0
    let t682 = circuit_mul(in203, in2); // Eval sumdlogdiv_b_den Horner step: multiply by xA2
    let t683 = circuit_add(in202, t682); // Eval sumdlogdiv_b_den Horner step: add coefficient_50
    let t684 = circuit_mul(t683, in2); // Eval sumdlogdiv_b_den Horner step: multiply by xA2
    let t685 = circuit_add(in201, t684); // Eval sumdlogdiv_b_den Horner step: add coefficient_49
    let t686 = circuit_mul(t685, in2); // Eval sumdlogdiv_b_den Horner step: multiply by xA2
    let t687 = circuit_add(in200, t686); // Eval sumdlogdiv_b_den Horner step: add coefficient_48
    let t688 = circuit_mul(t687, in2); // Eval sumdlogdiv_b_den Horner step: multiply by xA2
    let t689 = circuit_add(in199, t688); // Eval sumdlogdiv_b_den Horner step: add coefficient_47
    let t690 = circuit_mul(t689, in2); // Eval sumdlogdiv_b_den Horner step: multiply by xA2
    let t691 = circuit_add(in198, t690); // Eval sumdlogdiv_b_den Horner step: add coefficient_46
    let t692 = circuit_mul(t691, in2); // Eval sumdlogdiv_b_den Horner step: multiply by xA2
    let t693 = circuit_add(in197, t692); // Eval sumdlogdiv_b_den Horner step: add coefficient_45
    let t694 = circuit_mul(t693, in2); // Eval sumdlogdiv_b_den Horner step: multiply by xA2
    let t695 = circuit_add(in196, t694); // Eval sumdlogdiv_b_den Horner step: add coefficient_44
    let t696 = circuit_mul(t695, in2); // Eval sumdlogdiv_b_den Horner step: multiply by xA2
    let t697 = circuit_add(in195, t696); // Eval sumdlogdiv_b_den Horner step: add coefficient_43
    let t698 = circuit_mul(t697, in2); // Eval sumdlogdiv_b_den Horner step: multiply by xA2
    let t699 = circuit_add(in194, t698); // Eval sumdlogdiv_b_den Horner step: add coefficient_42
    let t700 = circuit_mul(t699, in2); // Eval sumdlogdiv_b_den Horner step: multiply by xA2
    let t701 = circuit_add(in193, t700); // Eval sumdlogdiv_b_den Horner step: add coefficient_41
    let t702 = circuit_mul(t701, in2); // Eval sumdlogdiv_b_den Horner step: multiply by xA2
    let t703 = circuit_add(in192, t702); // Eval sumdlogdiv_b_den Horner step: add coefficient_40
    let t704 = circuit_mul(t703, in2); // Eval sumdlogdiv_b_den Horner step: multiply by xA2
    let t705 = circuit_add(in191, t704); // Eval sumdlogdiv_b_den Horner step: add coefficient_39
    let t706 = circuit_mul(t705, in2); // Eval sumdlogdiv_b_den Horner step: multiply by xA2
    let t707 = circuit_add(in190, t706); // Eval sumdlogdiv_b_den Horner step: add coefficient_38
    let t708 = circuit_mul(t707, in2); // Eval sumdlogdiv_b_den Horner step: multiply by xA2
    let t709 = circuit_add(in189, t708); // Eval sumdlogdiv_b_den Horner step: add coefficient_37
    let t710 = circuit_mul(t709, in2); // Eval sumdlogdiv_b_den Horner step: multiply by xA2
    let t711 = circuit_add(in188, t710); // Eval sumdlogdiv_b_den Horner step: add coefficient_36
    let t712 = circuit_mul(t711, in2); // Eval sumdlogdiv_b_den Horner step: multiply by xA2
    let t713 = circuit_add(in187, t712); // Eval sumdlogdiv_b_den Horner step: add coefficient_35
    let t714 = circuit_mul(t713, in2); // Eval sumdlogdiv_b_den Horner step: multiply by xA2
    let t715 = circuit_add(in186, t714); // Eval sumdlogdiv_b_den Horner step: add coefficient_34
    let t716 = circuit_mul(t715, in2); // Eval sumdlogdiv_b_den Horner step: multiply by xA2
    let t717 = circuit_add(in185, t716); // Eval sumdlogdiv_b_den Horner step: add coefficient_33
    let t718 = circuit_mul(t717, in2); // Eval sumdlogdiv_b_den Horner step: multiply by xA2
    let t719 = circuit_add(in184, t718); // Eval sumdlogdiv_b_den Horner step: add coefficient_32
    let t720 = circuit_mul(t719, in2); // Eval sumdlogdiv_b_den Horner step: multiply by xA2
    let t721 = circuit_add(in183, t720); // Eval sumdlogdiv_b_den Horner step: add coefficient_31
    let t722 = circuit_mul(t721, in2); // Eval sumdlogdiv_b_den Horner step: multiply by xA2
    let t723 = circuit_add(in182, t722); // Eval sumdlogdiv_b_den Horner step: add coefficient_30
    let t724 = circuit_mul(t723, in2); // Eval sumdlogdiv_b_den Horner step: multiply by xA2
    let t725 = circuit_add(in181, t724); // Eval sumdlogdiv_b_den Horner step: add coefficient_29
    let t726 = circuit_mul(t725, in2); // Eval sumdlogdiv_b_den Horner step: multiply by xA2
    let t727 = circuit_add(in180, t726); // Eval sumdlogdiv_b_den Horner step: add coefficient_28
    let t728 = circuit_mul(t727, in2); // Eval sumdlogdiv_b_den Horner step: multiply by xA2
    let t729 = circuit_add(in179, t728); // Eval sumdlogdiv_b_den Horner step: add coefficient_27
    let t730 = circuit_mul(t729, in2); // Eval sumdlogdiv_b_den Horner step: multiply by xA2
    let t731 = circuit_add(in178, t730); // Eval sumdlogdiv_b_den Horner step: add coefficient_26
    let t732 = circuit_mul(t731, in2); // Eval sumdlogdiv_b_den Horner step: multiply by xA2
    let t733 = circuit_add(in177, t732); // Eval sumdlogdiv_b_den Horner step: add coefficient_25
    let t734 = circuit_mul(t733, in2); // Eval sumdlogdiv_b_den Horner step: multiply by xA2
    let t735 = circuit_add(in176, t734); // Eval sumdlogdiv_b_den Horner step: add coefficient_24
    let t736 = circuit_mul(t735, in2); // Eval sumdlogdiv_b_den Horner step: multiply by xA2
    let t737 = circuit_add(in175, t736); // Eval sumdlogdiv_b_den Horner step: add coefficient_23
    let t738 = circuit_mul(t737, in2); // Eval sumdlogdiv_b_den Horner step: multiply by xA2
    let t739 = circuit_add(in174, t738); // Eval sumdlogdiv_b_den Horner step: add coefficient_22
    let t740 = circuit_mul(t739, in2); // Eval sumdlogdiv_b_den Horner step: multiply by xA2
    let t741 = circuit_add(in173, t740); // Eval sumdlogdiv_b_den Horner step: add coefficient_21
    let t742 = circuit_mul(t741, in2); // Eval sumdlogdiv_b_den Horner step: multiply by xA2
    let t743 = circuit_add(in172, t742); // Eval sumdlogdiv_b_den Horner step: add coefficient_20
    let t744 = circuit_mul(t743, in2); // Eval sumdlogdiv_b_den Horner step: multiply by xA2
    let t745 = circuit_add(in171, t744); // Eval sumdlogdiv_b_den Horner step: add coefficient_19
    let t746 = circuit_mul(t745, in2); // Eval sumdlogdiv_b_den Horner step: multiply by xA2
    let t747 = circuit_add(in170, t746); // Eval sumdlogdiv_b_den Horner step: add coefficient_18
    let t748 = circuit_mul(t747, in2); // Eval sumdlogdiv_b_den Horner step: multiply by xA2
    let t749 = circuit_add(in169, t748); // Eval sumdlogdiv_b_den Horner step: add coefficient_17
    let t750 = circuit_mul(t749, in2); // Eval sumdlogdiv_b_den Horner step: multiply by xA2
    let t751 = circuit_add(in168, t750); // Eval sumdlogdiv_b_den Horner step: add coefficient_16
    let t752 = circuit_mul(t751, in2); // Eval sumdlogdiv_b_den Horner step: multiply by xA2
    let t753 = circuit_add(in167, t752); // Eval sumdlogdiv_b_den Horner step: add coefficient_15
    let t754 = circuit_mul(t753, in2); // Eval sumdlogdiv_b_den Horner step: multiply by xA2
    let t755 = circuit_add(in166, t754); // Eval sumdlogdiv_b_den Horner step: add coefficient_14
    let t756 = circuit_mul(t755, in2); // Eval sumdlogdiv_b_den Horner step: multiply by xA2
    let t757 = circuit_add(in165, t756); // Eval sumdlogdiv_b_den Horner step: add coefficient_13
    let t758 = circuit_mul(t757, in2); // Eval sumdlogdiv_b_den Horner step: multiply by xA2
    let t759 = circuit_add(in164, t758); // Eval sumdlogdiv_b_den Horner step: add coefficient_12
    let t760 = circuit_mul(t759, in2); // Eval sumdlogdiv_b_den Horner step: multiply by xA2
    let t761 = circuit_add(in163, t760); // Eval sumdlogdiv_b_den Horner step: add coefficient_11
    let t762 = circuit_mul(t761, in2); // Eval sumdlogdiv_b_den Horner step: multiply by xA2
    let t763 = circuit_add(in162, t762); // Eval sumdlogdiv_b_den Horner step: add coefficient_10
    let t764 = circuit_mul(t763, in2); // Eval sumdlogdiv_b_den Horner step: multiply by xA2
    let t765 = circuit_add(in161, t764); // Eval sumdlogdiv_b_den Horner step: add coefficient_9
    let t766 = circuit_mul(t765, in2); // Eval sumdlogdiv_b_den Horner step: multiply by xA2
    let t767 = circuit_add(in160, t766); // Eval sumdlogdiv_b_den Horner step: add coefficient_8
    let t768 = circuit_mul(t767, in2); // Eval sumdlogdiv_b_den Horner step: multiply by xA2
    let t769 = circuit_add(in159, t768); // Eval sumdlogdiv_b_den Horner step: add coefficient_7
    let t770 = circuit_mul(t769, in2); // Eval sumdlogdiv_b_den Horner step: multiply by xA2
    let t771 = circuit_add(in158, t770); // Eval sumdlogdiv_b_den Horner step: add coefficient_6
    let t772 = circuit_mul(t771, in2); // Eval sumdlogdiv_b_den Horner step: multiply by xA2
    let t773 = circuit_add(in157, t772); // Eval sumdlogdiv_b_den Horner step: add coefficient_5
    let t774 = circuit_mul(t773, in2); // Eval sumdlogdiv_b_den Horner step: multiply by xA2
    let t775 = circuit_add(in156, t774); // Eval sumdlogdiv_b_den Horner step: add coefficient_4
    let t776 = circuit_mul(t775, in2); // Eval sumdlogdiv_b_den Horner step: multiply by xA2
    let t777 = circuit_add(in155, t776); // Eval sumdlogdiv_b_den Horner step: add coefficient_3
    let t778 = circuit_mul(t777, in2); // Eval sumdlogdiv_b_den Horner step: multiply by xA2
    let t779 = circuit_add(in154, t778); // Eval sumdlogdiv_b_den Horner step: add coefficient_2
    let t780 = circuit_mul(t779, in2); // Eval sumdlogdiv_b_den Horner step: multiply by xA2
    let t781 = circuit_add(in153, t780); // Eval sumdlogdiv_b_den Horner step: add coefficient_1
    let t782 = circuit_mul(t781, in2); // Eval sumdlogdiv_b_den Horner step: multiply by xA2
    let t783 = circuit_add(in152, t782); // Eval sumdlogdiv_b_den Horner step: add coefficient_0
    let t784 = circuit_inverse(t783);
    let t785 = circuit_mul(t681, t784);
    let t786 = circuit_mul(in3, t785);
    let t787 = circuit_add(t585, t786);
    let t788 = circuit_mul(in4, t393);
    let t789 = circuit_mul(in5, t787);
    let t790 = circuit_sub(t788, t789);

    let modulus = get_BN254_modulus(); // BN254 prime field modulus

    let mut circuit_inputs = (t790,).new_inputs();
    // Prefill constants:

    // Fill inputs:
    circuit_inputs = circuit_inputs.next_2(A0.x); // in0
    circuit_inputs = circuit_inputs.next_2(A0.y); // in1
    circuit_inputs = circuit_inputs.next_2(A2.x); // in2
    circuit_inputs = circuit_inputs.next_2(A2.y); // in3
    circuit_inputs = circuit_inputs.next_2(coeff0); // in4
    circuit_inputs = circuit_inputs.next_2(coeff2); // in5
    let mut SumDlogDivBatched_a_num = SumDlogDivBatched.a_num;
    while let Option::Some(val) = SumDlogDivBatched_a_num.pop_front() {
        circuit_inputs = circuit_inputs.next_2(*val);
    };
    let mut SumDlogDivBatched_a_den = SumDlogDivBatched.a_den;
    while let Option::Some(val) = SumDlogDivBatched_a_den.pop_front() {
        circuit_inputs = circuit_inputs.next_2(*val);
    };
    let mut SumDlogDivBatched_b_num = SumDlogDivBatched.b_num;
    while let Option::Some(val) = SumDlogDivBatched_b_num.pop_front() {
        circuit_inputs = circuit_inputs.next_2(*val);
    };
    let mut SumDlogDivBatched_b_den = SumDlogDivBatched.b_den;
    while let Option::Some(val) = SumDlogDivBatched_b_den.pop_front() {
        circuit_inputs = circuit_inputs.next_2(*val);
    };
    // in6 - in203

    let outputs = circuit_inputs.done_2().eval(modulus).unwrap();
    let res: u384 = outputs.get_output(t790);
    return (res,);
}
