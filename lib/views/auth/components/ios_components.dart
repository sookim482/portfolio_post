import 'package:flutter/cupertino.dart';

import '../../../class/controller_node_class.dart';
import '../../../providers/auth_provider.dart';
import 'common_components.dart';

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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        CupertinoTextField(
          padding: this.padding ?? const EdgeInsets.only(top: 25.0, bottom: 3.0, left: 5.0),
          controller: this.textCt,
          style: const TextStyle(fontSize: 17.0),
          textAlignVertical: TextAlignVertical.bottom,
          placeholder: this.hintText,
          suffix: this.suffixIcon ?? null,
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide()),
          ),
          textInputAction: this.textInputAction ?? null,
          keyboardType: this.textInputType ?? null,
          obscureText: this.obscureText ?? false,
        ),
        Text(this.errorText ?? "", style: TextStyle(color: CupertinoColors.systemRed),),
      ],
    );
  }
}

class IosRedEye extends StatelessWidget {
  const IosRedEye({Key? key, required this.onPressed, required this.isPw1}) : super(key: key);

  final bool isPw1;
  final void Function(bool isPw1) onPressed;

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      child: const Icon(CupertinoIcons.eye, size: 20.0),
      onPressed: () => onPressed(isPw1),
    );
  }
}


class GenderWidget extends StatelessWidget {
  const GenderWidget({Key? key, required this.isMale, required this.onSelect}) : super(key: key);

  final bool isMale;
  final void Function(bool b) onSelect;

  Widget _gender({required String text, required bool isMale}){
    return GestureDetector(
      onTap: () => this.onSelect(isMale),
      child: Container(
        margin: const EdgeInsets.only(left: 15.0),
        decoration: BoxDecoration(
          border: isMale ? Border.all() : null,
        ),
        child: Text(text),
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
          this._gender(text: "M", isMale: this.isMale,),
          this._gender(text: "F", isMale: !this.isMale,),
        ],
      ),
    );
  }
}

class IosSignUpWidget extends StatelessWidget {
  const IosSignUpWidget({Key? key, required this.authProvider, required this.ctsNodes}) : super(key: key);

  final List<ControllerClass> ctsNodes;
  final AuthProvider authProvider;

  @override
  Widget build(BuildContext context) {
    Size _size = MediaQuery.of(context).size;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: _size.width * 0.08),
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
            suffixIcon: IosRedEye(onPressed: this.authProvider.onTapRedEye, isPw1: true),
            errorText: this.authProvider.pwErrorText,
            textInputAction: TextInputAction.next,
            obscureText: this.authProvider.pw1obscure,
          ),
          AuthTextField(
            textCt: this.ctsNodes.firstWhere((ControllerClass cn) => cn.name == "pw2Ct").textCt,
            hintText: "???????????? ??????",
            suffixIcon: IosRedEye(onPressed: this.authProvider.onTapRedEye, isPw1: false),
            obscureText: this.authProvider.pw2obscure,
            errorText: this.authProvider.pw2ErrorText,
          ),
          Container(
            width: _size.width * 0.79,
            margin: const EdgeInsets.all(12.0),
            child: Tos(
              iconData: CupertinoIcons.check_mark,
              onPressed: this.authProvider.checkTos,
              isChecked: this.authProvider.isTosChecked,
            ),
          ),
        ],
      ),
    );
  }
}

class IosLoginWidget extends StatelessWidget {
  const IosLoginWidget({Key? key, required this.authProvider, required this.ctsNodes}) : super(key: key);

  final List<ControllerClass> ctsNodes;
  final AuthProvider authProvider;

  @override
  Widget build(BuildContext context) {
    Size _size = MediaQuery.of(context).size;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: _size.width * 0.08),
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
            suffixIcon: IosRedEye(onPressed: this.authProvider.onTapRedEye, isPw1: true),
            errorText: this.authProvider.pwErrorText,
            textInputAction: TextInputAction.next,
            obscureText: this.authProvider.pw1obscure,
          ),
        ],
      ),
    );
  }
}