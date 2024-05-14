import { ShowToastEvent } from "lightning/platformShowToastEvent";
import Default_Error_Title from "@salesforce/label/c.Default_Error_Title";
import Default_Success_Title from "@salesforce/label/c.Default_Success_Title";
export function showErrorToast(error) {
  const event = new ShowToastEvent({
    title: Default_Error_Title,
    variant: "error",
    message: generateErrorMessage(error)
  });
  dispatchEvent(event);
}

export function showSuccessToast(message) {
  const event = new ShowToastEvent({
    title: Default_Success_Title,
    variant: "success",
    message: message
  });
  dispatchEvent(event);
}

export function generateErrorMessage(error) {
  let errorMessage;
  if (error.detail) {
    errorMessage = error.detail.message;
  } else if (error.body) {
    if (Array.isArray(error.body)) {
      errorMessage = error.body.map((e) => e.message).join(", ");
    } else if (typeof error.body.message === "string") {
      errorMessage = error.body.message;
    }
  } else {
    errorMessage = "";
  }

  return errorMessage;
}
