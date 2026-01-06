const String globalCurrency = 'zł';

double toGlobalCurrency({
  required double amount,
  required double rateToPln,
}) {
  return amount * rateToPln;
}

double walletValueToGlobal({
  required double walletValue,
  required double rateToPln,
}) {
  return walletValue * rateToPln;
}
