import 'package:flutter/material.dart';

import '../../../class/controller_node_class.dart';
import '../../../providers/auth_provider.dart';
import '../../../repos/variables.dart';
import 'common_components.dart' show Tos;

class AuthTextField extends StatelessWidget {
  const AuthTextField({Key? key,
    this.width,
    this.obscureText,
    this.suffixIcon,
    required this.textCt,
    required this.hintText,
    this.textInputAction,
    this.textInputType,
    this.errorText,
    this.padding,
  }) : super(key: key);

  final bool? obscureText;
  final Widget? suffixIcon;
  final TextEditingController? textCt;
  final String hintText;
  final double? width;
  final TextInputAction? textInputAction;
  final TextInputType? textInputType;
  final String? errorText;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: this.padding ?? const EdgeInsets.only(top: 22.0, right: 5.0, left: 5.0),
      child: TextField(
        controller: this.textCt,
        style: const TextStyle(fontSize: 17.0),
        textAlignVertical: TextAlignVertical.bottom,
        decoration: InputDecoration(
          counterText: "",
          focusedBorder: UnderlineInputBorder(),
          errorText: this.errorText ?? null,
          errorStyle: const TextStyle(height: 0.7, fontSize: 15.0),
          errorMaxLines: 3,
          errorBorder: UnderlineInputBorder(
            borderRadius: BorderRadius.circular(4.0),
            borderSide: const BorderSide(color: Colors.red, width: 2.0,),
          ),
          contentPadding: const EdgeInsets.only(bottom: 3.0),
          isDense: true,
          hintText: this.hintText,
          suffix: this.suffixIcon ?? null,
          suffixStyle: TextStyle(),
        ),
        textInputAction: this.textInputAction ?? null,
        keyboardType: this.textInputType ?? null,
        obscureText: this.obscureText ?? false,
      ),
    );
  }
}

class AndroidRedEye extends StatelessWidget {
  AndroidRedEye({Key? key, required this.onPressed, required this.isPw1}) : super(key: key);

  final bool isPw1;
  final void Function(bool isPw1) onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      constraints: BoxConstraints(maxHeight: 20.0,),
      padding: const EdgeInsets.all(0.0),
      icon: const Icon(Icons.remove_red_eye_outlined, size: 20.0),
      onPressed: () => onPressed(isPw1),
    );
  }
}

class AndroidSignUpWidget extends StatelessWidget {
  AndroidSignUpWidget({Key? key,
    required this.authProvider,
    required this.ctsNodes
  }) : super(key: key);

  final List<ControllerClass> ctsNodes;
  final AuthProvider authProvider;

  @override
  Widget build(BuildContext context) {
    Size _size = MediaQuery.of(context).size;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: _size.width * 0.08, vertical: 25.0),
      height: _size.height * 0.7,
      child: Column(
        children: <Widget>[
          Text("????????????", textAlign: TextAlign.center, style: TextStyle(fontSize: 30.0, fontWeight: FontWeight.w600),),
          AuthTextField(
            textCt: this.ctsNodes.firstWhere((ControllerClass cn) => cn.name == "nameCt").textCt,
            hintText: "??????",
            textInputAction: TextInputAction.next,
            errorText: this.authProvider.nameErrorText,
          ),
          AuthTextField(
            textCt: this.ctsNodes.firstWhere((ControllerClass cn) => cn.name == "emailCt").textCt,
            hintText: "?????????",
            errorText: this.authProvider.emailErrorText,
            textInputAction: TextInputAction.next,
            textInputType: TextInputType.emailAddress,
          ),
          GenderWidget(
            onSelect: this.authProvider.selectGender,
            isMale: this.authProvider.isMale,
          ),
          AuthTextField(
            textCt: this.ctsNodes.firstWhere((ControllerClass cn) => cn.name == "pw1Ct").textCt,
            hintText: "????????????",
            suffixIcon: AndroidRedEye(onPressed: this.authProvider.onTapRedEye, isPw1: true),
            errorText: this.authProvider.pwErrorText,
            textInputAction: TextInputAction.next,
            obscureText: this.authProvider.pw1obscure,
          ),
          AuthTextField(
            textCt: this.ctsNodes.firstWhere((ControllerClass cn) => cn.name == "pw2Ct").textCt,
            hintText: "???????????? ??????",
            suffixIcon: AndroidRedEye(onPressed: this.authProvider.onTapRedEye, isPw1: false),
            obscureText: this.authProvider.pw2obscure,
            errorText: this.authProvider.pw2ErrorText,
          ),
          Container(
            width: _size.width * 0.79,
            margin: const EdgeInsets.all(12.0),
            child: Tos(
              iconData: Icons.check,
              onPressed: this.authProvider.checkTos,
              isChecked: this.authProvider.isTosChecked,
            ),
          ),
        ],
      ),
    );
  }
}

class GenderWidget extends StatelessWidget {
  const GenderWidget({Key? key, required this.isMale, required this.onSelect}) : super(key: key);

  final bool isMale;
  final void Function(bool b) onSelect;

  Widget _gender({required IconData icon, required bool isMale}){
    return GestureDetector(
      onTap: () => this.onSelect(isMale),
      child: Container(
        margin: const EdgeInsets.only(left: 15.0),
        decoration: BoxDecoration(
          border: isMale ? Border.all() : null,
        ),
        child: Icon(icon),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 10.0, top: 25.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          const Text("??????", style: TextStyle(fontSize: 16.0,)),
          this._gender(icon: Icons.male_outlined, isMale: this.isMale,),
          this._gender(icon: Icons.female_outlined, isMale: !this.isMale,),
        ],
      ),
    );
  }
}

class AndroidLoginWidget extends StatelessWidget {
  const AndroidLoginWidget({Key? key, required this.authProvider, required this.ctsNodes}) : super(key: key);

  final List<ControllerClass> ctsNodes;
  final AuthProvider authProvider;

  @override
  Widget build(BuildContext context) {
    Size _size = MediaQuery.of(context).size;

    return Container(
      margin: EdgeInsets.only(left: _size.width * 0.08, right: _size.width * 0.08, top: 70.0),
      height: _size.height * 0.4,
      child: Column(
        children: <Widget>[
          Padding(child: Text("Mooky's Dev Posts", style: const TextStyle(fontSize: 30.0, fontWeight: FontWeight.w600),), padding: EdgeInsets.only(bottom: 35.0)),
          AuthTextField(
            padding: const EdgeInsets.only(top: 40.0, right: 5.0, left: 5.0, bottom: 30.0),
            textCt: this.ctsNodes.firstWhere((ControllerClass cn) => cn.name == "emailCt").textCt,
            hintText: "?????????",
            errorText: this.authProvider.emailErrorText,
            textInputAction: TextInputAction.next,
            textInputType: TextInputType.emailAddress,
          ),
          AuthTextField(
            textCt: this.ctsNodes.firstWhere((ControllerClass cn) => cn.name == "pw1Ct").textCt,
            hintText: "????????????",
            suffixIcon: AndroidRedEye(onPressed: this.authProvider.onTapRedEye, isPw1: true),
            errorText: this.authProvider.pwErrorText,
            textInputAction: TextInputAction.next,
            obscureText: this.authProvider.pw1obscure,
          ),
        ],
      ),
    );
  }
}