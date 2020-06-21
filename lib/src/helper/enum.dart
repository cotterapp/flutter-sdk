const CotterBaseURL = 'https://www.cotter.app/api/v0';
const CotterJSBaseURL = 'https://js.cotter.app/app';
const EmailType = "EMAIL";
const PhoneType = "PHONE";
const Mobile = "MOBILE";
const TrustedDeviceMethod = "TRUSTED_DEVICE";
const LOGGED_IN_USER_KEY = "COTTER_USER";
const LoginWithDeviceEvent = "LOGIN_WITH_DEVICE";
const TrustedDeviceAlgorithm = "ED25519";

const JwtAlgorithm = "ES256";
const JwtKID = "SPACE_JWT_PUBLIC:8028AAA3-EC2D-4BAA-BE7A-7C8359CCB9F9";

const ACCESS_TOKEN_KEY = 'ACCESS_TOKEN';
const REFRESH_TOKEN_KEY = 'REFRESH_TOKEN';
const ID_TOKEN_KEY = 'ID_TOKEN';
const TOKEN_TYPE_KEY = 'TOKEN_TYPE';

const AuthRequestDuration = 3 * 60;

const VERIFICATION_STATE_LENGTH = 10;
const SMS = "SMS";
const WHATSAPP = "WHATSAPP";
enum PhoneChannel { SMS, WHATSAPP }

const DefaultPhoneChannel = PhoneChannel.SMS;
const DefaultPhoneChannels = [PhoneChannel.SMS, PhoneChannel.WHATSAPP];
