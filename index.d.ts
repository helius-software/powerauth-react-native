declare module "react-native-powerauth" {

    enum PA2ActivationState {
        /**
         The activation is just created.
        */
        PA2ActivationState_Created  = 1,
        
        /**
         The OTP was already used.
        */
        PA2ActivationState_OTP_Used = 2,
        
        /**
         The shared secure context is valid and active.
        */
        PA2ActivationState_Active   = 3,
        
        /**
         The activation is blocked.
        */
        PA2ActivationState_Blocked  = 4,
        
        /**
         The activation doesn't exist anymore.
        */
        PA2ActivationState_Removed  = 5,
        
        /**
         The activation is technically blocked. You cannot use it anymore
        for the signature calculations.
        */
        PA2ActivationState_Deadlock	= 128,
    }

    interface ActivationStatus {
        "status": PA2ActivationState,
        "currentFailCount": number;
        "maxAllowedFailCount": number;
        "remainingFailCount" : number;
    }

    export function createActivation(credentials: any): Promise<string>;

    export function commitActivation(password: string): Promise<string>;
    
    export function removeActivationLocal(): void;
    
    export function hasValidActivation(): Promise<boolean>;
    
    export function fetchActivationStatus(): Promise<ActivationStatus>;
}