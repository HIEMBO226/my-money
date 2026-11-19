import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('fr'),
    Locale('en'),
  ];

  /// Nom de l'application
  ///
  /// In fr, this message translates to:
  /// **'My money'**
  String get appName;

  /// No description provided for @navDashboard.
  ///
  /// In fr, this message translates to:
  /// **'Accueil'**
  String get navDashboard;

  /// No description provided for @navTransactions.
  ///
  /// In fr, this message translates to:
  /// **'Transactions'**
  String get navTransactions;

  /// No description provided for @navBudgets.
  ///
  /// In fr, this message translates to:
  /// **'Budgets'**
  String get navBudgets;

  /// No description provided for @navStatistics.
  ///
  /// In fr, this message translates to:
  /// **'Statistiques'**
  String get navStatistics;

  /// No description provided for @navSettings.
  ///
  /// In fr, this message translates to:
  /// **'Paramètres'**
  String get navSettings;

  /// No description provided for @add.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter'**
  String get add;

  /// No description provided for @edit.
  ///
  /// In fr, this message translates to:
  /// **'Modifier'**
  String get edit;

  /// No description provided for @delete.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer'**
  String get delete;

  /// No description provided for @save.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In fr, this message translates to:
  /// **'Annuler'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In fr, this message translates to:
  /// **'Confirmer'**
  String get confirm;

  /// No description provided for @search.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher'**
  String get search;

  /// No description provided for @filter.
  ///
  /// In fr, this message translates to:
  /// **'Filtrer'**
  String get filter;

  /// No description provided for @retry.
  ///
  /// In fr, this message translates to:
  /// **'Réessayer'**
  String get retry;

  /// No description provided for @close.
  ///
  /// In fr, this message translates to:
  /// **'Fermer'**
  String get close;

  /// No description provided for @loading.
  ///
  /// In fr, this message translates to:
  /// **'Chargement en cours'**
  String get loading;

  /// No description provided for @transactionTypeExpense.
  ///
  /// In fr, this message translates to:
  /// **'Dépense'**
  String get transactionTypeExpense;

  /// No description provided for @transactionTypeIncome.
  ///
  /// In fr, this message translates to:
  /// **'Revenu'**
  String get transactionTypeIncome;

  /// No description provided for @transactionTypeTransfer.
  ///
  /// In fr, this message translates to:
  /// **'Transfert'**
  String get transactionTypeTransfer;

  /// No description provided for @accountTypeCash.
  ///
  /// In fr, this message translates to:
  /// **'Espèces'**
  String get accountTypeCash;

  /// No description provided for @accountTypeBank.
  ///
  /// In fr, this message translates to:
  /// **'Banque'**
  String get accountTypeBank;

  /// No description provided for @accountTypeMobileMoney.
  ///
  /// In fr, this message translates to:
  /// **'Mobile Money'**
  String get accountTypeMobileMoney;

  /// No description provided for @accountTypeSavings.
  ///
  /// In fr, this message translates to:
  /// **'Épargne'**
  String get accountTypeSavings;

  /// No description provided for @frequencyDaily.
  ///
  /// In fr, this message translates to:
  /// **'Quotidien'**
  String get frequencyDaily;

  /// No description provided for @frequencyWeekly.
  ///
  /// In fr, this message translates to:
  /// **'Hebdomadaire'**
  String get frequencyWeekly;

  /// No description provided for @frequencyMonthly.
  ///
  /// In fr, this message translates to:
  /// **'Mensuel'**
  String get frequencyMonthly;

  /// No description provided for @frequencyYearly.
  ///
  /// In fr, this message translates to:
  /// **'Annuel'**
  String get frequencyYearly;

  /// No description provided for @categoryFood.
  ///
  /// In fr, this message translates to:
  /// **'Alimentation'**
  String get categoryFood;

  /// No description provided for @categoryGroceries.
  ///
  /// In fr, this message translates to:
  /// **'Courses'**
  String get categoryGroceries;

  /// No description provided for @categoryTransport.
  ///
  /// In fr, this message translates to:
  /// **'Transport'**
  String get categoryTransport;

  /// No description provided for @categoryHousing.
  ///
  /// In fr, this message translates to:
  /// **'Logement'**
  String get categoryHousing;

  /// No description provided for @categoryBills.
  ///
  /// In fr, this message translates to:
  /// **'Factures'**
  String get categoryBills;

  /// No description provided for @categoryHealth.
  ///
  /// In fr, this message translates to:
  /// **'Santé'**
  String get categoryHealth;

  /// No description provided for @categoryLeisure.
  ///
  /// In fr, this message translates to:
  /// **'Loisirs'**
  String get categoryLeisure;

  /// No description provided for @categoryShopping.
  ///
  /// In fr, this message translates to:
  /// **'Shopping'**
  String get categoryShopping;

  /// No description provided for @categoryEducation.
  ///
  /// In fr, this message translates to:
  /// **'Éducation'**
  String get categoryEducation;

  /// No description provided for @categoryOtherExpense.
  ///
  /// In fr, this message translates to:
  /// **'Autres dépenses'**
  String get categoryOtherExpense;

  /// No description provided for @categorySalary.
  ///
  /// In fr, this message translates to:
  /// **'Salaire'**
  String get categorySalary;

  /// No description provided for @categoryFreelance.
  ///
  /// In fr, this message translates to:
  /// **'Freelance'**
  String get categoryFreelance;

  /// No description provided for @categoryInvestment.
  ///
  /// In fr, this message translates to:
  /// **'Investissements'**
  String get categoryInvestment;

  /// No description provided for @categoryGifts.
  ///
  /// In fr, this message translates to:
  /// **'Cadeaux'**
  String get categoryGifts;

  /// No description provided for @categoryOtherIncome.
  ///
  /// In fr, this message translates to:
  /// **'Autres revenus'**
  String get categoryOtherIncome;

  /// No description provided for @totalBalance.
  ///
  /// In fr, this message translates to:
  /// **'Solde total'**
  String get totalBalance;

  /// No description provided for @monthlyIncome.
  ///
  /// In fr, this message translates to:
  /// **'Revenus du mois'**
  String get monthlyIncome;

  /// No description provided for @monthlyExpenses.
  ///
  /// In fr, this message translates to:
  /// **'Dépenses du mois'**
  String get monthlyExpenses;

  /// No description provided for @recentTransactions.
  ///
  /// In fr, this message translates to:
  /// **'Transactions récentes'**
  String get recentTransactions;

  /// No description provided for @addTransaction.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter une transaction'**
  String get addTransaction;

  /// No description provided for @amount.
  ///
  /// In fr, this message translates to:
  /// **'Montant'**
  String get amount;

  /// No description provided for @date.
  ///
  /// In fr, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @category.
  ///
  /// In fr, this message translates to:
  /// **'Catégorie'**
  String get category;

  /// No description provided for @account.
  ///
  /// In fr, this message translates to:
  /// **'Compte'**
  String get account;

  /// No description provided for @note.
  ///
  /// In fr, this message translates to:
  /// **'Note'**
  String get note;

  /// No description provided for @selectCategory.
  ///
  /// In fr, this message translates to:
  /// **'Choisir une catégorie'**
  String get selectCategory;

  /// No description provided for @selectAccount.
  ///
  /// In fr, this message translates to:
  /// **'Choisir un compte'**
  String get selectAccount;

  /// No description provided for @budgetTitle.
  ///
  /// In fr, this message translates to:
  /// **'Budgets'**
  String get budgetTitle;

  /// No description provided for @budgetProgress.
  ///
  /// In fr, this message translates to:
  /// **'Progression'**
  String get budgetProgress;

  /// No description provided for @budgetWarning.
  ///
  /// In fr, this message translates to:
  /// **'Attention : 80 % du budget atteint'**
  String get budgetWarning;

  /// No description provided for @budgetExceeded.
  ///
  /// In fr, this message translates to:
  /// **'Budget dépassé'**
  String get budgetExceeded;

  /// No description provided for @noBudgets.
  ///
  /// In fr, this message translates to:
  /// **'Aucun budget défini'**
  String get noBudgets;

  /// No description provided for @savingsGoals.
  ///
  /// In fr, this message translates to:
  /// **'Objectifs d\'épargne'**
  String get savingsGoals;

  /// No description provided for @targetAmount.
  ///
  /// In fr, this message translates to:
  /// **'Montant cible'**
  String get targetAmount;

  /// No description provided for @currentAmount.
  ///
  /// In fr, this message translates to:
  /// **'Montant actuel'**
  String get currentAmount;

  /// No description provided for @deadline.
  ///
  /// In fr, this message translates to:
  /// **'Date limite'**
  String get deadline;

  /// No description provided for @noGoals.
  ///
  /// In fr, this message translates to:
  /// **'Aucun objectif d\'épargne'**
  String get noGoals;

  /// No description provided for @noTransactions.
  ///
  /// In fr, this message translates to:
  /// **'Aucune transaction'**
  String get noTransactions;

  /// No description provided for @noAccounts.
  ///
  /// In fr, this message translates to:
  /// **'Aucun compte'**
  String get noAccounts;

  /// No description provided for @noCategories.
  ///
  /// In fr, this message translates to:
  /// **'Aucune catégorie'**
  String get noCategories;

  /// No description provided for @currency.
  ///
  /// In fr, this message translates to:
  /// **'Devise'**
  String get currency;

  /// No description provided for @dateFormat.
  ///
  /// In fr, this message translates to:
  /// **'Format de date'**
  String get dateFormat;

  /// No description provided for @theme.
  ///
  /// In fr, this message translates to:
  /// **'Thème'**
  String get theme;

  /// No description provided for @themeLight.
  ///
  /// In fr, this message translates to:
  /// **'Clair'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In fr, this message translates to:
  /// **'Sombre'**
  String get themeDark;

  /// No description provided for @themeSystem.
  ///
  /// In fr, this message translates to:
  /// **'Système'**
  String get themeSystem;

  /// No description provided for @language.
  ///
  /// In fr, this message translates to:
  /// **'Langue'**
  String get language;

  /// No description provided for @pin.
  ///
  /// In fr, this message translates to:
  /// **'Code PIN'**
  String get pin;

  /// No description provided for @biometrics.
  ///
  /// In fr, this message translates to:
  /// **'Biométrie'**
  String get biometrics;

  /// No description provided for @exportData.
  ///
  /// In fr, this message translates to:
  /// **'Exporter les données'**
  String get exportData;

  /// No description provided for @importData.
  ///
  /// In fr, this message translates to:
  /// **'Importer les données'**
  String get importData;

  /// No description provided for @currencyXof.
  ///
  /// In fr, this message translates to:
  /// **'Franc CFA (XOF)'**
  String get currencyXof;

  /// No description provided for @currencyEur.
  ///
  /// In fr, this message translates to:
  /// **'Euro (EUR)'**
  String get currencyEur;

  /// No description provided for @currencyUsd.
  ///
  /// In fr, this message translates to:
  /// **'Dollar américain (USD)'**
  String get currencyUsd;

  /// No description provided for @currencyGbp.
  ///
  /// In fr, this message translates to:
  /// **'Livre sterling (GBP)'**
  String get currencyGbp;

  /// No description provided for @currencyCad.
  ///
  /// In fr, this message translates to:
  /// **'Dollar canadien (CAD)'**
  String get currencyCad;

  /// No description provided for @currencyChf.
  ///
  /// In fr, this message translates to:
  /// **'Franc suisse (CHF)'**
  String get currencyChf;

  /// No description provided for @currencyMad.
  ///
  /// In fr, this message translates to:
  /// **'Dirham marocain (MAD)'**
  String get currencyMad;

  /// No description provided for @currencyTnd.
  ///
  /// In fr, this message translates to:
  /// **'Dinar tunisien (TND)'**
  String get currencyTnd;

  /// No description provided for @currencyXaf.
  ///
  /// In fr, this message translates to:
  /// **'Franc CFA (XAF)'**
  String get currencyXaf;

  /// No description provided for @currencyGnf.
  ///
  /// In fr, this message translates to:
  /// **'Franc guinéen (GNF)'**
  String get currencyGnf;

  /// No description provided for @errorGeneric.
  ///
  /// In fr, this message translates to:
  /// **'Une erreur inattendue s\'est produite.'**
  String get errorGeneric;

  /// No description provided for @errorDatabase.
  ///
  /// In fr, this message translates to:
  /// **'Erreur lors de l\'accès aux données locales.'**
  String get errorDatabase;

  /// No description provided for @errorValidation.
  ///
  /// In fr, this message translates to:
  /// **'Veuillez vérifier les champs saisis.'**
  String get errorValidation;

  /// No description provided for @errorExport.
  ///
  /// In fr, this message translates to:
  /// **'Erreur lors de l\'exportation des données.'**
  String get errorExport;

  /// No description provided for @today.
  ///
  /// In fr, this message translates to:
  /// **'Aujourd\'hui'**
  String get today;

  /// No description provided for @yesterday.
  ///
  /// In fr, this message translates to:
  /// **'Hier'**
  String get yesterday;

  /// No description provided for @confirmDelete.
  ///
  /// In fr, this message translates to:
  /// **'Confirmer la suppression'**
  String get confirmDelete;

  /// No description provided for @deleteConfirmMessage.
  ///
  /// In fr, this message translates to:
  /// **'Cette action est irréversible. Voulez-vous continuer ?'**
  String get deleteConfirmMessage;

  /// No description provided for @accountsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Comptes'**
  String get accountsTitle;

  /// No description provided for @addAccount.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter un compte'**
  String get addAccount;

  /// No description provided for @editAccount.
  ///
  /// In fr, this message translates to:
  /// **'Modifier le compte'**
  String get editAccount;

  /// No description provided for @accountName.
  ///
  /// In fr, this message translates to:
  /// **'Nom du compte'**
  String get accountName;

  /// No description provided for @accountNameHint.
  ///
  /// In fr, this message translates to:
  /// **'Ex. Compte courant, Orange Money...'**
  String get accountNameHint;

  /// No description provided for @accountType.
  ///
  /// In fr, this message translates to:
  /// **'Type de compte'**
  String get accountType;

  /// No description provided for @initialBalance.
  ///
  /// In fr, this message translates to:
  /// **'Solde initial'**
  String get initialBalance;

  /// No description provided for @initialBalanceNote.
  ///
  /// In fr, this message translates to:
  /// **'Solde initial'**
  String get initialBalanceNote;

  /// No description provided for @noAccountsSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Ajoutez vos comptes (espèces, banque, mobile money, épargne) pour suivre vos soldes.'**
  String get noAccountsSubtitle;

  /// No description provided for @accountCreated.
  ///
  /// In fr, this message translates to:
  /// **'Compte créé avec succès'**
  String get accountCreated;

  /// No description provided for @accountUpdated.
  ///
  /// In fr, this message translates to:
  /// **'Compte mis à jour'**
  String get accountUpdated;

  /// No description provided for @accountDeleted.
  ///
  /// In fr, this message translates to:
  /// **'Compte supprimé'**
  String get accountDeleted;

  /// No description provided for @accountDeleteLinkedError.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de supprimer un compte lié à des transactions.'**
  String get accountDeleteLinkedError;

  /// No description provided for @transfer.
  ///
  /// In fr, this message translates to:
  /// **'Transférer'**
  String get transfer;

  /// No description provided for @transferTitle.
  ///
  /// In fr, this message translates to:
  /// **'Transfert entre comptes'**
  String get transferTitle;

  /// No description provided for @fromAccount.
  ///
  /// In fr, this message translates to:
  /// **'Compte source'**
  String get fromAccount;

  /// No description provided for @toAccount.
  ///
  /// In fr, this message translates to:
  /// **'Compte destination'**
  String get toAccount;

  /// No description provided for @transferSuccess.
  ///
  /// In fr, this message translates to:
  /// **'Transfert effectué avec succès'**
  String get transferSuccess;

  /// No description provided for @transferSameAccountError.
  ///
  /// In fr, this message translates to:
  /// **'Les comptes source et destination doivent être différents.'**
  String get transferSameAccountError;

  /// No description provided for @invalidAmountError.
  ///
  /// In fr, this message translates to:
  /// **'Veuillez saisir un montant valide supérieur à zéro.'**
  String get invalidAmountError;

  /// No description provided for @requiredFieldError.
  ///
  /// In fr, this message translates to:
  /// **'Ce champ est obligatoire.'**
  String get requiredFieldError;

  /// No description provided for @categoriesTitle.
  ///
  /// In fr, this message translates to:
  /// **'Catégories'**
  String get categoriesTitle;

  /// No description provided for @addCategory.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter une catégorie'**
  String get addCategory;

  /// No description provided for @editCategory.
  ///
  /// In fr, this message translates to:
  /// **'Modifier la catégorie'**
  String get editCategory;

  /// No description provided for @categoryName.
  ///
  /// In fr, this message translates to:
  /// **'Nom de la catégorie'**
  String get categoryName;

  /// No description provided for @categoryNameHint.
  ///
  /// In fr, this message translates to:
  /// **'Ex. Café, Abonnements...'**
  String get categoryNameHint;

  /// No description provided for @categoryType.
  ///
  /// In fr, this message translates to:
  /// **'Type'**
  String get categoryType;

  /// No description provided for @expensesTab.
  ///
  /// In fr, this message translates to:
  /// **'Dépenses'**
  String get expensesTab;

  /// No description provided for @incomesTab.
  ///
  /// In fr, this message translates to:
  /// **'Revenus'**
  String get incomesTab;

  /// No description provided for @defaultBadge.
  ///
  /// In fr, this message translates to:
  /// **'Par défaut'**
  String get defaultBadge;

  /// No description provided for @noCategoriesSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Créez des catégories pour organiser vos revenus et dépenses.'**
  String get noCategoriesSubtitle;

  /// No description provided for @categoryCreated.
  ///
  /// In fr, this message translates to:
  /// **'Catégorie créée avec succès'**
  String get categoryCreated;

  /// No description provided for @categoryUpdated.
  ///
  /// In fr, this message translates to:
  /// **'Catégorie mise à jour'**
  String get categoryUpdated;

  /// No description provided for @categoryDeleted.
  ///
  /// In fr, this message translates to:
  /// **'Catégorie supprimée'**
  String get categoryDeleted;

  /// No description provided for @categoryDeleteDefaultError.
  ///
  /// In fr, this message translates to:
  /// **'Les catégories par défaut ne peuvent pas être supprimées.'**
  String get categoryDeleteDefaultError;

  /// No description provided for @categoryDeleteUsedError.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de supprimer une catégorie utilisée par des transactions ou budgets.'**
  String get categoryDeleteUsedError;

  /// No description provided for @selectIcon.
  ///
  /// In fr, this message translates to:
  /// **'Icône'**
  String get selectIcon;

  /// No description provided for @selectColor.
  ///
  /// In fr, this message translates to:
  /// **'Couleur'**
  String get selectColor;

  /// No description provided for @settingsManagementSection.
  ///
  /// In fr, this message translates to:
  /// **'Gestion'**
  String get settingsManagementSection;

  /// No description provided for @manageAccountsSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Gérer vos comptes et effectuer des transferts'**
  String get manageAccountsSubtitle;

  /// No description provided for @manageCategoriesSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Personnaliser vos catégories de revenus et dépenses'**
  String get manageCategoriesSubtitle;

  /// No description provided for @editTransaction.
  ///
  /// In fr, this message translates to:
  /// **'Modifier la transaction'**
  String get editTransaction;

  /// No description provided for @transactionCreated.
  ///
  /// In fr, this message translates to:
  /// **'Transaction enregistrée'**
  String get transactionCreated;

  /// No description provided for @transactionUpdated.
  ///
  /// In fr, this message translates to:
  /// **'Transaction mise à jour'**
  String get transactionUpdated;

  /// No description provided for @transactionDeleted.
  ///
  /// In fr, this message translates to:
  /// **'Transaction supprimée'**
  String get transactionDeleted;

  /// No description provided for @searchTransactionsHint.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher par note, catégorie ou compte...'**
  String get searchTransactionsHint;

  /// No description provided for @noTransactionsSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Appuyez sur + pour enregistrer votre première dépense ou votre premier revenu.'**
  String get noTransactionsSubtitle;

  /// No description provided for @noMatchingTransactions.
  ///
  /// In fr, this message translates to:
  /// **'Aucune transaction trouvée'**
  String get noMatchingTransactions;

  /// No description provided for @noMatchingTransactionsSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Essayez d\'ajuster ou de réinitialiser vos filtres.'**
  String get noMatchingTransactionsSubtitle;

  /// No description provided for @resetFilters.
  ///
  /// In fr, this message translates to:
  /// **'Réinitialiser les filtres'**
  String get resetFilters;

  /// No description provided for @applyFilters.
  ///
  /// In fr, this message translates to:
  /// **'Appliquer'**
  String get applyFilters;

  /// No description provided for @filtersTitle.
  ///
  /// In fr, this message translates to:
  /// **'Filtres'**
  String get filtersTitle;

  /// No description provided for @period.
  ///
  /// In fr, this message translates to:
  /// **'Période'**
  String get period;

  /// No description provided for @allPeriods.
  ///
  /// In fr, this message translates to:
  /// **'Toutes les dates'**
  String get allPeriods;

  /// No description provided for @thisMonth.
  ///
  /// In fr, this message translates to:
  /// **'Ce mois'**
  String get thisMonth;

  /// No description provided for @lastMonth.
  ///
  /// In fr, this message translates to:
  /// **'Mois dernier'**
  String get lastMonth;

  /// No description provided for @last30Days.
  ///
  /// In fr, this message translates to:
  /// **'30 derniers jours'**
  String get last30Days;

  /// No description provided for @customPeriod.
  ///
  /// In fr, this message translates to:
  /// **'Personnalisée'**
  String get customPeriod;

  /// No description provided for @allTypes.
  ///
  /// In fr, this message translates to:
  /// **'Tous'**
  String get allTypes;

  /// No description provided for @allAccounts.
  ///
  /// In fr, this message translates to:
  /// **'Tous les comptes'**
  String get allAccounts;

  /// No description provided for @allCategories.
  ///
  /// In fr, this message translates to:
  /// **'Toutes les catégories'**
  String get allCategories;

  /// No description provided for @amountRange.
  ///
  /// In fr, this message translates to:
  /// **'Fourchette de montant'**
  String get amountRange;

  /// No description provided for @minAmount.
  ///
  /// In fr, this message translates to:
  /// **'Montant min.'**
  String get minAmount;

  /// No description provided for @maxAmount.
  ///
  /// In fr, this message translates to:
  /// **'Montant max.'**
  String get maxAmount;

  /// No description provided for @loadMore.
  ///
  /// In fr, this message translates to:
  /// **'Charger plus'**
  String get loadMore;

  /// No description provided for @attachment.
  ///
  /// In fr, this message translates to:
  /// **'Pièce jointe'**
  String get attachment;

  /// No description provided for @addAttachment.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter un justificatif'**
  String get addAttachment;

  /// No description provided for @removeAttachment.
  ///
  /// In fr, this message translates to:
  /// **'Retirer la pièce jointe'**
  String get removeAttachment;

  /// No description provided for @cameraOption.
  ///
  /// In fr, this message translates to:
  /// **'Prendre une photo'**
  String get cameraOption;

  /// No description provided for @galleryOption.
  ///
  /// In fr, this message translates to:
  /// **'Choisir dans la galerie'**
  String get galleryOption;

  /// No description provided for @noteHint.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter une note (optionnel)...'**
  String get noteHint;

  /// No description provided for @noAccountsPrompt.
  ///
  /// In fr, this message translates to:
  /// **'Créez d\'abord un compte pour enregistrer des transactions.'**
  String get noAccountsPrompt;

  /// No description provided for @clearAmount.
  ///
  /// In fr, this message translates to:
  /// **'Effacer le montant'**
  String get clearAmount;

  /// No description provided for @backspace.
  ///
  /// In fr, this message translates to:
  /// **'Effacer le dernier chiffre'**
  String get backspace;

  /// No description provided for @selectType.
  ///
  /// In fr, this message translates to:
  /// **'Type de transaction'**
  String get selectType;

  /// No description provided for @uncategorized.
  ///
  /// In fr, this message translates to:
  /// **'Sans catégorie'**
  String get uncategorized;

  /// No description provided for @monthlyNet.
  ///
  /// In fr, this message translates to:
  /// **'Solde du mois'**
  String get monthlyNet;

  /// No description provided for @expensesByCategory.
  ///
  /// In fr, this message translates to:
  /// **'Dépenses par catégorie'**
  String get expensesByCategory;

  /// No description provided for @incomesByCategory.
  ///
  /// In fr, this message translates to:
  /// **'Revenus par catégorie'**
  String get incomesByCategory;

  /// No description provided for @sixMonthTrend.
  ///
  /// In fr, this message translates to:
  /// **'Évolution sur 6 mois'**
  String get sixMonthTrend;

  /// No description provided for @seeAll.
  ///
  /// In fr, this message translates to:
  /// **'Voir tout'**
  String get seeAll;

  /// No description provided for @noExpensesThisMonth.
  ///
  /// In fr, this message translates to:
  /// **'Aucune dépense ce mois-ci'**
  String get noExpensesThisMonth;

  /// No description provided for @noDataForPeriod.
  ///
  /// In fr, this message translates to:
  /// **'Aucune donnée sur cette période'**
  String get noDataForPeriod;

  /// No description provided for @previousMonth.
  ///
  /// In fr, this message translates to:
  /// **'Mois précédent'**
  String get previousMonth;

  /// No description provided for @nextMonth.
  ///
  /// In fr, this message translates to:
  /// **'Mois suivant'**
  String get nextMonth;

  /// No description provided for @accountsCount.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{Aucun compte} =1{1 compte} other{{count} comptes}}'**
  String accountsCount(int count);

  /// No description provided for @period3Months.
  ///
  /// In fr, this message translates to:
  /// **'3 mois'**
  String get period3Months;

  /// No description provided for @period6Months.
  ///
  /// In fr, this message translates to:
  /// **'6 mois'**
  String get period6Months;

  /// No description provided for @periodThisYear.
  ///
  /// In fr, this message translates to:
  /// **'Cette année'**
  String get periodThisYear;

  /// No description provided for @netSavings.
  ///
  /// In fr, this message translates to:
  /// **'Solde net'**
  String get netSavings;

  /// No description provided for @savingsRate.
  ///
  /// In fr, this message translates to:
  /// **'Taux d\'épargne'**
  String get savingsRate;

  /// No description provided for @incomeVsExpense.
  ///
  /// In fr, this message translates to:
  /// **'Revenus vs Dépenses'**
  String get incomeVsExpense;

  /// No description provided for @categoryDetails.
  ///
  /// In fr, this message translates to:
  /// **'Détail par catégorie'**
  String get categoryDetails;

  /// No description provided for @welcomeDashboardSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Créez votre premier compte ou enregistrez une transaction pour voir votre synthèse financière.'**
  String get welcomeDashboardSubtitle;

  /// No description provided for @addBudget.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter un budget'**
  String get addBudget;

  /// No description provided for @editBudget.
  ///
  /// In fr, this message translates to:
  /// **'Modifier le budget'**
  String get editBudget;

  /// No description provided for @budgetLimit.
  ///
  /// In fr, this message translates to:
  /// **'Plafond mensuel'**
  String get budgetLimit;

  /// No description provided for @budgetSpent.
  ///
  /// In fr, this message translates to:
  /// **'Dépensé'**
  String get budgetSpent;

  /// No description provided for @budgetRemaining.
  ///
  /// In fr, this message translates to:
  /// **'Restant'**
  String get budgetRemaining;

  /// No description provided for @budgetOverBy.
  ///
  /// In fr, this message translates to:
  /// **'Dépassé de {amount}'**
  String budgetOverBy(String amount);

  /// No description provided for @budgetTotalMonthly.
  ///
  /// In fr, this message translates to:
  /// **'Budget mensuel total'**
  String get budgetTotalMonthly;

  /// No description provided for @noBudgetsSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Fixez un plafond mensuel par catégorie pour maîtriser vos dépenses et recevoir des alertes à 80 % et 100 %.'**
  String get noBudgetsSubtitle;

  /// No description provided for @budgetSaved.
  ///
  /// In fr, this message translates to:
  /// **'Budget enregistré'**
  String get budgetSaved;

  /// No description provided for @budgetDeleted.
  ///
  /// In fr, this message translates to:
  /// **'Budget supprimé'**
  String get budgetDeleted;

  /// No description provided for @budgetAlertWarningTitle.
  ///
  /// In fr, this message translates to:
  /// **'Alerte budget (80 %)'**
  String get budgetAlertWarningTitle;

  /// No description provided for @budgetAlertExceededTitle.
  ///
  /// In fr, this message translates to:
  /// **'Budget dépassé (100 %)'**
  String get budgetAlertExceededTitle;

  /// No description provided for @budgetAlertBody.
  ///
  /// In fr, this message translates to:
  /// **'{category} : {percentage} % utilisé ({spent} / {limit})'**
  String budgetAlertBody(
    String category,
    int percentage,
    String spent,
    String limit,
  );

  /// No description provided for @allCategoriesBudgeted.
  ///
  /// In fr, this message translates to:
  /// **'Toutes vos catégories de dépenses ont déjà un budget pour ce mois.'**
  String get allCategoriesBudgeted;

  /// No description provided for @recurringTitle.
  ///
  /// In fr, this message translates to:
  /// **'Transactions récurrentes'**
  String get recurringTitle;

  /// No description provided for @manageRecurringSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Loyer, abonnements, salaire générés automatiquement'**
  String get manageRecurringSubtitle;

  /// No description provided for @addRecurring.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter une récurrence'**
  String get addRecurring;

  /// No description provided for @editRecurring.
  ///
  /// In fr, this message translates to:
  /// **'Modifier la récurrence'**
  String get editRecurring;

  /// No description provided for @noRecurring.
  ///
  /// In fr, this message translates to:
  /// **'Aucune transaction récurrente'**
  String get noRecurring;

  /// No description provided for @noRecurringSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Programmez vos loyers, abonnements ou salaires pour les générer automatiquement à l\'ouverture de l\'application.'**
  String get noRecurringSubtitle;

  /// No description provided for @frequency.
  ///
  /// In fr, this message translates to:
  /// **'Fréquence'**
  String get frequency;

  /// No description provided for @nextDueDate.
  ///
  /// In fr, this message translates to:
  /// **'Prochaine échéance'**
  String get nextDueDate;

  /// No description provided for @endDateOptional.
  ///
  /// In fr, this message translates to:
  /// **'Date de fin (optionnel)'**
  String get endDateOptional;

  /// No description provided for @noEndDate.
  ///
  /// In fr, this message translates to:
  /// **'Aucune date de fin'**
  String get noEndDate;

  /// No description provided for @recurringCreated.
  ///
  /// In fr, this message translates to:
  /// **'Transaction récurrente enregistrée'**
  String get recurringCreated;

  /// No description provided for @recurringUpdated.
  ///
  /// In fr, this message translates to:
  /// **'Transaction récurrente mise à jour'**
  String get recurringUpdated;

  /// No description provided for @recurringDeleted.
  ///
  /// In fr, this message translates to:
  /// **'Transaction récurrente supprimée'**
  String get recurringDeleted;

  /// No description provided for @recurringActiveLabel.
  ///
  /// In fr, this message translates to:
  /// **'Activer {name}'**
  String recurringActiveLabel(String name);

  /// No description provided for @recurringPaused.
  ///
  /// In fr, this message translates to:
  /// **'En pause'**
  String get recurringPaused;

  /// No description provided for @runDueNow.
  ///
  /// In fr, this message translates to:
  /// **'Générer les échéances dues'**
  String get runDueNow;

  /// No description provided for @recurringGeneratedCount.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{Aucune échéance due à générer} =1{1 transaction générée} other{{count} transactions générées}}'**
  String recurringGeneratedCount(int count);

  /// No description provided for @manageGoalsSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Suivre votre épargne vers vos projets'**
  String get manageGoalsSubtitle;

  /// No description provided for @addGoal.
  ///
  /// In fr, this message translates to:
  /// **'Nouvel objectif'**
  String get addGoal;

  /// No description provided for @editGoal.
  ///
  /// In fr, this message translates to:
  /// **'Modifier l\'objectif'**
  String get editGoal;

  /// No description provided for @goalName.
  ///
  /// In fr, this message translates to:
  /// **'Nom de l\'objectif'**
  String get goalName;

  /// No description provided for @goalNameHint.
  ///
  /// In fr, this message translates to:
  /// **'Ex. Fonds d\'urgence, Voyage, Voiture...'**
  String get goalNameHint;

  /// No description provided for @noGoalsSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Créez des objectifs d\'épargne avec un montant cible et une date limite pour suivre votre progression.'**
  String get noGoalsSubtitle;

  /// No description provided for @goalCreated.
  ///
  /// In fr, this message translates to:
  /// **'Objectif créé avec succès'**
  String get goalCreated;

  /// No description provided for @goalUpdated.
  ///
  /// In fr, this message translates to:
  /// **'Objectif mis à jour'**
  String get goalUpdated;

  /// No description provided for @goalDeleted.
  ///
  /// In fr, this message translates to:
  /// **'Objectif supprimé'**
  String get goalDeleted;

  /// No description provided for @contribute.
  ///
  /// In fr, this message translates to:
  /// **'Contribuer'**
  String get contribute;

  /// No description provided for @contributeTitle.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter une contribution'**
  String get contributeTitle;

  /// No description provided for @contributionAdded.
  ///
  /// In fr, this message translates to:
  /// **'Contribution ajoutée'**
  String get contributionAdded;

  /// No description provided for @goalCompleted.
  ///
  /// In fr, this message translates to:
  /// **'Objectif atteint !'**
  String get goalCompleted;

  /// No description provided for @deadlineOptional.
  ///
  /// In fr, this message translates to:
  /// **'Date limite (optionnel)'**
  String get deadlineOptional;

  /// No description provided for @noDeadline.
  ///
  /// In fr, this message translates to:
  /// **'Aucune date limite'**
  String get noDeadline;

  /// No description provided for @linkedAccountOptional.
  ///
  /// In fr, this message translates to:
  /// **'Compte d\'épargne associé (optionnel)'**
  String get linkedAccountOptional;

  /// No description provided for @noLinkedAccount.
  ///
  /// In fr, this message translates to:
  /// **'Aucun compte associé'**
  String get noLinkedAccount;

  /// No description provided for @daysRemaining.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{Échéance aujourd\'hui} =1{1 jour restant} other{{count} jours restants}}'**
  String daysRemaining(int count);

  /// No description provided for @deadlinePassed.
  ///
  /// In fr, this message translates to:
  /// **'Date limite dépassée'**
  String get deadlinePassed;

  /// No description provided for @totalSaved.
  ///
  /// In fr, this message translates to:
  /// **'Total épargné'**
  String get totalSaved;

  /// No description provided for @settingsPreferencesSection.
  ///
  /// In fr, this message translates to:
  /// **'Préférences'**
  String get settingsPreferencesSection;

  /// No description provided for @settingsDataSection.
  ///
  /// In fr, this message translates to:
  /// **'Données'**
  String get settingsDataSection;

  /// No description provided for @exportImportTitle.
  ///
  /// In fr, this message translates to:
  /// **'Export & Sauvegarde'**
  String get exportImportTitle;

  /// No description provided for @exportImportSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'CSV, rapport PDF et sauvegarde JSON chiffrée'**
  String get exportImportSubtitle;

  /// No description provided for @languageFrench.
  ///
  /// In fr, this message translates to:
  /// **'Français'**
  String get languageFrench;

  /// No description provided for @languageEnglish.
  ///
  /// In fr, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @exportCsvTitle.
  ///
  /// In fr, this message translates to:
  /// **'Exporter en CSV'**
  String get exportCsvTitle;

  /// No description provided for @exportCsvSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Tableau compatible Excel de toutes vos transactions'**
  String get exportCsvSubtitle;

  /// No description provided for @exportPdfTitle.
  ///
  /// In fr, this message translates to:
  /// **'Exporter un rapport PDF'**
  String get exportPdfTitle;

  /// No description provided for @exportPdfSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Synthèse des comptes et historique formaté'**
  String get exportPdfSubtitle;

  /// No description provided for @encryptedBackupSection.
  ///
  /// In fr, this message translates to:
  /// **'Sauvegarde locale chiffrée (AES-256)'**
  String get encryptedBackupSection;

  /// No description provided for @backupJsonTitle.
  ///
  /// In fr, this message translates to:
  /// **'Créer une sauvegarde chiffrée'**
  String get backupJsonTitle;

  /// No description provided for @backupJsonSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Exporte toutes vos données en JSON chiffré par mot de passe'**
  String get backupJsonSubtitle;

  /// No description provided for @restoreJsonTitle.
  ///
  /// In fr, this message translates to:
  /// **'Restaurer une sauvegarde'**
  String get restoreJsonTitle;

  /// No description provided for @restoreJsonSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Remplace les données locales depuis un fichier de sauvegarde'**
  String get restoreJsonSubtitle;

  /// No description provided for @backupPasswordTitle.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe de chiffrement'**
  String get backupPasswordTitle;

  /// No description provided for @restorePasswordTitle.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe de la sauvegarde'**
  String get restorePasswordTitle;

  /// No description provided for @passwordLabel.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe'**
  String get passwordLabel;

  /// No description provided for @confirmPasswordLabel.
  ///
  /// In fr, this message translates to:
  /// **'Confirmer le mot de passe'**
  String get confirmPasswordLabel;

  /// No description provided for @passwordMinLengthError.
  ///
  /// In fr, this message translates to:
  /// **'Le mot de passe doit contenir au moins 6 caractères.'**
  String get passwordMinLengthError;

  /// No description provided for @passwordMismatchError.
  ///
  /// In fr, this message translates to:
  /// **'Les mots de passe ne correspondent pas.'**
  String get passwordMismatchError;

  /// No description provided for @exportSuccess.
  ///
  /// In fr, this message translates to:
  /// **'Export généré et prêt à être partagé'**
  String get exportSuccess;

  /// No description provided for @restoreConfirmTitle.
  ///
  /// In fr, this message translates to:
  /// **'Restaurer la sauvegarde ?'**
  String get restoreConfirmTitle;

  /// No description provided for @restoreConfirmMessage.
  ///
  /// In fr, this message translates to:
  /// **'Toutes vos données actuelles seront remplacées par celles de la sauvegarde.'**
  String get restoreConfirmMessage;

  /// No description provided for @restoreSuccess.
  ///
  /// In fr, this message translates to:
  /// **'Sauvegarde restaurée ({transactions} transactions, {accounts} comptes)'**
  String restoreSuccess(int transactions, int accounts);

  /// No description provided for @invalidBackupError.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe incorrect ou fichier de sauvegarde invalide.'**
  String get invalidBackupError;

  /// No description provided for @settingsSecuritySection.
  ///
  /// In fr, this message translates to:
  /// **'Sécurité'**
  String get settingsSecuritySection;

  /// No description provided for @securityTitle.
  ///
  /// In fr, this message translates to:
  /// **'Sécurité et confidentialité'**
  String get securityTitle;

  /// No description provided for @securitySubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Code PIN, biométrie, verrouillage automatique'**
  String get securitySubtitle;

  /// No description provided for @pinEnabledStatus.
  ///
  /// In fr, this message translates to:
  /// **'Code PIN activé'**
  String get pinEnabledStatus;

  /// No description provided for @pinDisabledStatus.
  ///
  /// In fr, this message translates to:
  /// **'Désactivé'**
  String get pinDisabledStatus;

  /// No description provided for @enablePin.
  ///
  /// In fr, this message translates to:
  /// **'Activer le code PIN'**
  String get enablePin;

  /// No description provided for @changePin.
  ///
  /// In fr, this message translates to:
  /// **'Modifier le code PIN'**
  String get changePin;

  /// No description provided for @disablePin.
  ///
  /// In fr, this message translates to:
  /// **'Désactiver le code PIN'**
  String get disablePin;

  /// No description provided for @enterCurrentPin.
  ///
  /// In fr, this message translates to:
  /// **'Saisissez votre code PIN actuel'**
  String get enterCurrentPin;

  /// No description provided for @enterNewPin.
  ///
  /// In fr, this message translates to:
  /// **'Choisissez un code PIN à 4 chiffres'**
  String get enterNewPin;

  /// No description provided for @confirmNewPin.
  ///
  /// In fr, this message translates to:
  /// **'Confirmez votre code PIN'**
  String get confirmNewPin;

  /// No description provided for @enterPinToUnlock.
  ///
  /// In fr, this message translates to:
  /// **'Saisissez votre code PIN pour déverrouiller My money'**
  String get enterPinToUnlock;

  /// No description provided for @wrongPinError.
  ///
  /// In fr, this message translates to:
  /// **'Code PIN incorrect. Veuillez réessayer.'**
  String get wrongPinError;

  /// No description provided for @pinMismatchError.
  ///
  /// In fr, this message translates to:
  /// **'Les codes PIN ne correspondent pas.'**
  String get pinMismatchError;

  /// No description provided for @pinSavedSuccess.
  ///
  /// In fr, this message translates to:
  /// **'Code PIN enregistré'**
  String get pinSavedSuccess;

  /// No description provided for @pinRemovedSuccess.
  ///
  /// In fr, this message translates to:
  /// **'Code PIN désactivé'**
  String get pinRemovedSuccess;

  /// No description provided for @biometricsReason.
  ///
  /// In fr, this message translates to:
  /// **'Authentifiez-vous pour déverrouiller My money'**
  String get biometricsReason;

  /// No description provided for @biometricsSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Utiliser l\'empreinte digitale ou Face ID'**
  String get biometricsSubtitle;

  /// No description provided for @biometricsUnavailable.
  ///
  /// In fr, this message translates to:
  /// **'Non disponible sur cet appareil'**
  String get biometricsUnavailable;

  /// No description provided for @useBiometrics.
  ///
  /// In fr, this message translates to:
  /// **'Déverrouiller par biométrie'**
  String get useBiometrics;

  /// No description provided for @autoLockTimeout.
  ///
  /// In fr, this message translates to:
  /// **'Verrouillage automatique'**
  String get autoLockTimeout;

  /// No description provided for @autoLockImmediate.
  ///
  /// In fr, this message translates to:
  /// **'Immédiat en arrière-plan'**
  String get autoLockImmediate;

  /// No description provided for @autoLockMinutes.
  ///
  /// In fr, this message translates to:
  /// **'{minutes, plural, =1{Après 1 minute} other{Après {minutes} minutes}}'**
  String autoLockMinutes(int minutes);

  /// No description provided for @hideInAppSwitcher.
  ///
  /// In fr, this message translates to:
  /// **'Masquer dans les apps récentes'**
  String get hideInAppSwitcher;

  /// No description provided for @hideInAppSwitcherSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Affiche un écran de confidentialité dans l\'aperçu multitâche'**
  String get hideInAppSwitcherSubtitle;

  /// No description provided for @lockNow.
  ///
  /// In fr, this message translates to:
  /// **'Verrouiller maintenant'**
  String get lockNow;

  /// No description provided for @pinDigitEntered.
  ///
  /// In fr, this message translates to:
  /// **'{count} chiffres saisis sur {total}'**
  String pinDigitEntered(int count, int total);

  /// No description provided for @settingsDeveloperSection.
  ///
  /// In fr, this message translates to:
  /// **'Outils développeur (Debug)'**
  String get settingsDeveloperSection;

  /// No description provided for @loadDemoData.
  ///
  /// In fr, this message translates to:
  /// **'Charger les données de démonstration'**
  String get loadDemoData;

  /// No description provided for @loadDemoDataSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Ajoute des comptes, transactions, budgets, récurrences et objectifs fictifs'**
  String get loadDemoDataSubtitle;

  /// No description provided for @loadDemoDataConfirmTitle.
  ///
  /// In fr, this message translates to:
  /// **'Charger les données de démo ?'**
  String get loadDemoDataConfirmTitle;

  /// No description provided for @loadDemoDataConfirmBody.
  ///
  /// In fr, this message translates to:
  /// **'Cette action remplace ou complète la base locale avec un jeu de données réaliste sur 6 mois (mode debug uniquement).'**
  String get loadDemoDataConfirmBody;

  /// No description provided for @demoDataLoaded.
  ///
  /// In fr, this message translates to:
  /// **'Données de démo chargées ({accounts} comptes, {transactions} transactions)'**
  String demoDataLoaded(int accounts, int transactions);

  /// No description provided for @resetAllData.
  ///
  /// In fr, this message translates to:
  /// **'Réinitialiser toutes les données'**
  String get resetAllData;

  /// No description provided for @resetAllDataSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Supprime toutes les données locales et restaure les catégories par défaut'**
  String get resetAllDataSubtitle;

  /// No description provided for @resetAllDataConfirmTitle.
  ///
  /// In fr, this message translates to:
  /// **'Tout réinitialiser ?'**
  String get resetAllDataConfirmTitle;

  /// No description provided for @resetAllDataConfirmBody.
  ///
  /// In fr, this message translates to:
  /// **'Tous les comptes, transactions, budgets, récurrences et objectifs seront définitivement supprimés.'**
  String get resetAllDataConfirmBody;

  /// No description provided for @allDataReset.
  ///
  /// In fr, this message translates to:
  /// **'Toutes les données locales ont été réinitialisées'**
  String get allDataReset;

  /// No description provided for @aboutAppSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'100 % hors ligne • Vos données restent sur votre appareil'**
  String get aboutAppSubtitle;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
